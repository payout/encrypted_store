module Ribbon
  RSpec.describe EncryptedStore do
    let(:instance) { EncryptedStore::Instance.new }

    describe '#config' do
      describe '#decrypt_key' do
        context 'with decrypt_key config set' do
          it 'should call decrypt_key proc', :test do
            instance.config { |c| c.decrypt_key { |dek, primary| dek + "def" } }
            expect(instance.decrypt_key("abc", true)).to eq "abcdef"
          end
        end # with decrypt_key config set

        context 'without decrypt_key config' do
          it 'should default to args passed in' do
            expect(instance.decrypt_key("abc", true)).to eq ["abc", true]
          end
        end # without decrypt_key config
      end # #decrypt_key

      describe '#encrypt_key' do
        context 'with encrypt_key config set' do
          it 'should call encrypt_key proc', :test do
            instance.config { |c| c.encrypt_key { |dek, primary| dek + "123" } }
            expect(instance.encrypt_key("abc", true)).to eq "abc123"
          end
        end # with encrypt_key config set

        context 'without encrypt_key config' do
          it 'should default to args passed in' do
            expect(instance.encrypt_key("abc", true)).to eq ["abc", true]
          end
        end # without encrypt_key config
      end # #encrypt_key
    end # #config
  end # EncryptedStore
end # Ribbon::EncryptedStore