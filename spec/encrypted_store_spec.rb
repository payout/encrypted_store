module Ribbon
  RSpec.describe EncryptedStore do
    let(:instance) { EncryptedStore::Instance.new }

    describe '#config' do
      describe '#decrypt_key' do
        context 'with decrypt_key config set' do
          it 'should call decrypt_key proc' do
            instance.config { |c| c.decrypt_key { |dek, primary| dek + "def" } }
            expect(instance.decrypt_key(1, "abc", true)).to eq "abcdef"
          end

          context 'cached decrypted key' do
            before {
              instance.config { |c|
                c.decrypt_key { |dek, primary|
                  @counter ||= 0
                  key = dek + "world #{@counter}"
                  @counter += 1
                  key
                }
              }
            }

            it 'should cache the decrypted key for each encryption key record' do
              expect(instance.decrypt_key(1, "hello", true)).to eq "helloworld 0"
              expect(instance.decrypt_key(1, "hello", true)).to eq "helloworld 0"
            end

            it 'should decrypt new keys using the config method' do
              expect(instance.decrypt_key(1, "hello", true)).to eq "helloworld 0"
              expect(instance.decrypt_key(2, "hello", true)).to eq "helloworld 1"
              expect(instance.decrypt_key(2, "hello", true)).to eq "helloworld 1"
            end
          end # cached decrypted key
        end # with decrypt_key config set

        context 'without decrypt_key config' do
          it 'should default to args passed in' do
            expect(instance.decrypt_key(1, "abc", true)).to eq "abc"
          end
        end # without decrypt_key config
      end # #decrypt_key

      describe '#encrypt_key' do
        context 'with encrypt_key config set' do
          it 'should call encrypt_key proc' do
            instance.config { |c| c.encrypt_key { |dek, primary| dek + "123" } }
            expect(instance.encrypt_key("abc", true)).to eq "abc123"
          end
        end # with encrypt_key config set

        context 'without encrypt_key config' do
          it 'should default to args passed in' do
            expect(instance.encrypt_key("abc", true)).to eq "abc"
          end
        end # without encrypt_key config
      end # #encrypt_key
    end # #config
  end # EncryptedStore
end # Ribbon::EncryptedStore