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
      before { encrypted_data }
      subject { hash.decrypt(dek, encrypted_data) }

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