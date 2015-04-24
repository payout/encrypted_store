module Ribbon::EncryptedStore
  RSpec.describe CryptoHash do
    let(:data) { {} }
    let(:hash) { CryptoHash.new(data) }

    describe '#initialize' do
      subject { hash }

      context 'with empty hash' do
        it { is_expected.to eq({}) }
      end # with empty hash

      context 'with some data' do
        let(:data) { {test: 1} }

        it { is_expected.to eq({test: 1}) }
      end # with some data

      context 'without data' do
        let(:hash) { CryptoHash.new }

        it { is_expected.to eq({}) }
      end # without data
    end # #intialize

    describe '#encrypt' do
      let(:dek) { "abc123" }
      let(:salt) { "salt" }
      let(:encrypted_data) { hash.encrypt(dek, salt) }

      context 'with salt too big' do
        let(:data) { {test: 1} }
        let(:salt) { "lkjsdfljasdflkajsddfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjlkjsdfljasdflkajsdfasdlfkjasdlfkj;" }
        subject { encrypted_data }

        it 'should raise error' do
          expect { subject }.to raise_error Errors::SaltTooBigError
        end
      end

      context 'with valid salt' do
        subject { CryptoHash.decrypt(dek, encrypted_data) }

        context 'empty hash' do
          subject { encrypted_data }
          it { is_expected.to eq nil }
        end # empty hash

        context 'with 1 field' do
          let(:data) { {test: 1} }

          it { is_expected.to eq data }
        end # with 1 field

        context 'with multiple fields' do
          let(:data) { {test: 1, another: "hello"} }

          it { is_expected.to eq data }
        end # with multiple fields
      end
    end # #encrypt

    describe '#decrypt' do
      let(:dek) { "abc123" }
      let(:salt) { "salt" }
      let(:data) { {hello: "world"} }
      let(:encrypted_data) { hash.encrypt(dek, salt) }

      subject { CryptoHash.decrypt(dek, encrypted_data) }

      context 'without salt header' do
        def encrypt_data_without_header(data, dek, salt)
          key_and_iv = OpenSSL::PKCS5.pbkdf2_hmac(
            dek,
            salt,
            4096,
            48,
            OpenSSL::Digest::SHA256.new
          )

          key = key_and_iv[0..31]
          iv  = key_and_iv[32..-1]

          encryptor = OpenSSL::Cipher::AES256.new(:CBC).encrypt
          encryptor.key = key
          encryptor.iv = iv

          encryptor.update(data.to_json) + encryptor.final
        end

        let(:encrypted_data) { encrypt_data_without_header(data, dek, salt) }

        it 'should raise error' do
          expect { subject }.to raise_error
        end
      end # without salt header

      context 'with bad salt' do
        def encrypt_data_with_wrong_salt_header(data, dek, salt)
          key_and_iv = OpenSSL::PKCS5.pbkdf2_hmac(
            dek,
            salt,
            4096,
            48,
            OpenSSL::Digest::SHA256.new
          )

          key = key_and_iv[0..31]
          iv  = key_and_iv[32..-1]

          encryptor = OpenSSL::Cipher::AES256.new(:CBC).encrypt
          encryptor.key = key
          encryptor.iv = iv

          "\x01" + salt.bytes.length.chr + "wrong-salt" + encryptor.update(data.to_json) + encryptor.final
        end

        let(:encrypted_data) { encrypt_data_with_wrong_salt_header(data, dek, salt) }

        it 'should raise error' do
          expect { subject }.to raise_error Errors::ChecksumFailedError
        end
      end

      context 'with valid salt' do
        context 'empty hash' do
          let(:data) { {} }

          it { is_expected.to eq data }
        end # empty hash

        context 'with 1 field' do
          let(:data) { {test: 1} }

          it { is_expected.to eq data }
        end # with 1 field

        context 'with multiple fields' do
          let(:data) { {test: 1, another: "hello"} }

          it { is_expected.to eq data }
        end # with multiple fields
      end # with valid salt
    end # #decrypt
  end # CryptoHash
end # Ribbon::EncryptedStore