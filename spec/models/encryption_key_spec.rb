module Ribbon::EncryptedStore
  module Mixins
    module ActiveRecordMixin
      RSpec.describe EncryptionKey do
        describe '#primary_encryption_key' do
          subject { EncryptionKey.primary_encryption_key }

          context 'with no keys set yet' do
            it { is_expected.to eq EncryptionKey.last }
          end

          context 'with a primary key set' do
            before { EncryptionKey.new_key }
            it { is_expected.to eq EncryptionKey.last }
          end # with a primary key set

          context 'with multiple keys rotated' do
            before { 3.times { EncryptionKey.new_key } }
            it { is_expected.to eq EncryptionKey.last }
          end # with multiple keys rotated
        end # #primary_encryption_key

        describe '#new_key' do
          let(:custom_key) { nil }
          let(:new_key) { EncryptionKey.new_key(custom_key) }
          before { new_key }

          context 'without custom_key arg' do
            it 'should be created' do
              expect(new_key).to eq EncryptionKey.last
            end

            it 'should make the new key primary' do
              expect(new_key.primary).to eq true
            end

            it 'should only have 1 primary' do
              expect(EncryptionKey.where(primary: true).count).to eq 1
            end
          end # without custom_key arg

          context 'with custom_key arg' do
            let(:custom_key) { SecureRandom.random_bytes(32) }

            it 'should be created' do
              expect(new_key).to eq EncryptionKey.last
            end

            it 'should use the custom_key' do
              expect(new_key.dek).to eq custom_key
            end

            it 'should make the new key primary' do
              expect(new_key.primary).to eq true
            end

            it 'should only have 1 primary' do
              expect(EncryptionKey.where(primary: true).count).to eq 1
            end
          end # with custom_key arg
        end # #new_key

        describe '#retire_keys' do
          let(:key_ids) { [] }

          context 'with key_ids arg' do
          end

          context 'without key_ids arg' do
          end
        end # #retire_keys

        describe '#rotate_keys' do
        end # #rotate_keys
      end # EncryptionKey
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore