module EncryptedStore
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

        ##
        # For issue#13
        it 'should return nil for undefined keys' do
          expect(subject[:undefined_key]).to be nil
        end
      end # with some data

      context 'without data' do
        let(:hash) { CryptoHash.new }

        it { is_expected.to eq({}) }

        ##
        # For issue#13
        it 'should return nil for undefined keys' do
          expect(subject[:undefined_key]).to be nil
        end
      end # without data
    end # #intialize

    describe '#encrypt' do
      let(:dek) { "abc123" }
      let(:salt) { "salt" }
      let(:iter_mag) { 10 }
      let(:encrypted_data) { hash.encrypt(dek, salt, iter_mag) }
      subject { encrypted_data }

      context 'with salt too big' do
        let(:data) { {test: 1} }
        let(:salt) { "\x01" * 256 }

        it 'should raise error' do
          expect { subject }.to raise_error Errors::InvalidSaltSize, 'too long'
        end
      end

      context 'with salt max length' do
        let(:data) { {test: 1} }
        let(:salt) { "\x01" * 255 }

        it 'should not raise error' do
          expect { subject }.not_to raise_error
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

      context 'with iteration magnitude -1' do
        let(:iter_mag) { -1 }

        context 'with 128bit key' do
          let(:dek) { "\x01".force_encoding('BINARY') * 16 }
          let(:salt) { "\x01".force_encoding('BINARY') * 16 }
          let(:data) { { key: 'value' } }
          it { expect { subject }.to raise_error Errors::InvalidKeySize, 'must be exactly 256 bits' }
        end # with 128bit key

        context 'with 256bit key' do
          context 'with 128bit salt' do
            let(:dek) { "\x01".force_encoding('BINARY') * 32 }
            let(:salt) { "\x01".force_encoding('BINARY') * 16 }
            let(:data) { { key: 'value' } }
            it { is_expected.to start_with "\x02\x10\xFF".force_encoding('BINARY') }
          end # with 128bit salt

          context 'with 32bit salt' do
            let(:dek) { "\x01".force_encoding('BINARY') * 32 }
            let(:salt) { "\x01".force_encoding('BINARY') * 4 }
            let(:data) { { key: 'value' } }

            it 'should raise invalid salt error' do
              expect { subject }.to raise_error Errors::InvalidSaltSize, 'must be exactly 128 bits'
            end
          end # with 32bit salt
        end # with 256bit key
      end # with iteration magnitude -1
    end # #encrypt

    describe '#decrypt' do
      let(:dek) { "abc123" }
      let(:salt) { "salt" }
      let(:iter_mag) { 10 }
      let(:data) { {hello: "world"} }
      let(:encrypted_data) { hash.encrypt(dek, salt, iter_mag) }

      subject { CryptoHash.decrypt(dek, encrypted_data) }

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
      end # with bad salt

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

      context 'with iter_mag -1' do
        let(:iter_mag) { -1 }
        let(:dek) { "\x01".force_encoding('BINARY') * 32 }
        let(:salt) { "\x01".force_encoding('BINARY') * 16 }
        let(:data) { {hello: 'world', how: 'are you?'} }
        it { is_expected.to eq data }
      end # with iter_mag -1

      context 'with v1 data' do
        let(:encrypted_data) { "\x01\x0Eversion 1 salt\x83/\xF6T\x8D6\x1E\xA3n\xB7!\xED)\xCC\xAF\x15\x9E\xA9\x13d\x05\xBA\x05\xFE\\\xD4/Ck\x91\xE0{\xB4\x01K\xEE" }
        let(:dek) { 'version 1 key' }
        let(:salt) { 'version 1 salt' }
        it { is_expected.to eq(encrypted: "using version 1") }
      end # with v1 data

      context 'with v2 data' do
        let(:encrypted_data) { "\x02\x0E\rversion 2 salt\xAC\x83\xFD2\xB9\x01Le\xA1\xAE\x16\x02\xED\n\xFD\xFC\xB6?\xAC\xDB\xDA\xB8C\x90\xD3\xCB\xA8G\x05W\xF7\x16\xBB\xCD\xD8E" }
        let(:dek) { 'version 2 key' }
        let(:salt) { 'version 2 salt' }
        it { is_expected.to eq(encrypted: "using version 2") }
      end # with v2 data

      context 'with unsupported version' do
        let(:encrypted_data) { "\xFF" }
        it { expect { subject }.to raise_error Errors::UnsupportedVersionError, "Unsupported encrypted data version: 255" }
      end # with unsupported version
    end # #decrypt
  end # CryptoHash
end # EncryptedStore
