module Ribbon
  RSpec.describe EncryptedStore do
    let(:instance) { EncryptedStore::Instance.new }

    describe "mixing in" do
      subject { DummyModel.new }

      ##
      # Github Issue #10
      it 'should raise Dummy Model method_missing error' do
        expect { subject.missing_method }.to raise_error NoMethodError, /undefined method `missing_method' for #<DummyModel/
      end
    end # mixing in

    describe '#config' do
      describe '#decrypt_key' do
        context 'with decrypt_key config set' do
          it 'should call decrypt_key proc' do
            instance.config { |c| c.decrypt_key { |dek, primary| dek + "def" } }
            expect(instance.decrypt_key("abc", true)).to eq "abcdef"
          end
        end # with decrypt_key config set

        context 'without decrypt_key config' do
          it 'should default to args passed in' do
            expect(instance.decrypt_key("abc", true)).to eq "abc"
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

    describe '#retrieve_dek' do
      let(:key_model) {
        double('key model').tap { |m|
          allow(m).to receive(:find) { key_model_instance }
        }
      }

      let(:key_model_instance) {
        double('key model instance').tap { |i|
          allow(i).to receive(:decrypted_key) { 'truthy' }
        }
      }

      it 'should only call decrypted_key once' do
        expect(key_model_instance).to receive(:decrypted_key).once
        instance.retrieve_dek(key_model, 1)
        instance.retrieve_dek(key_model, 1)
        instance.retrieve_dek(key_model, 1)
      end
    end # #retrieve_dek
  end # EncryptedStore
end # Ribbon::EncryptedStore