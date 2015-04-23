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
      def decrypt_data
        key_and_iv = OpenSSL::PKCS5.pbkdf2_hmac(
          dek,
          salt,
          4096,
          48,
          'SHA256'
        )

        key = key_and_iv[0..31]
        iv  = key_and_iv[32..-1]

        decryptor = OpenSSL::Cipher::AES256.new(:CBC).decrypt
        decryptor.key = key
        decryptor.iv = iv

        Hash[JSON.parse(decryptor.update(encrypted_data) + decryptor.final).map { |k,v| [k.to_sym, v] }]
      end

      let(:dek) { "abc123" }
      let(:salt) { "salt" }
      let(:encrypted_data) { hash.encrypt(dek, salt) }
      before { encrypted_data }
      subject { decrypt_data }

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
    end # #encrypt

    describe '#decrypt' do
    end # #decrypt
  end # CryptoHash
end # Ribbon::EncryptedStore