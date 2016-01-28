module EncryptedStore
  module ActiveRecord
    RSpec.describe Mixin do
      describe '#attr_encrypted' do
        let(:dummy_record) { DummyModel.new }

        it 'should set the args (as symbols) in encrypted_store_data' do
          expect(DummyModel._encrypted_store_data).to eq(encrypted_attributes: [:name, :age, :username])
        end

        it 'should create setters and getters for each arg' do
          expect(dummy_record.respond_to?(:age)).to eq true
          expect(dummy_record.respond_to?(:age=)).to eq true
          expect(dummy_record.respond_to?(:name)).to eq true
          expect(dummy_record.respond_to?(:name=)).to eq true
        end

        it 'should set and get the values when saved' do
          dummy_record.age = 4
          dummy_record.name = "joe"
          dummy_record.save
          expect(dummy_record.age).to eq 4
          expect(dummy_record.name).to eq "joe"
        end
      end

      describe '#encrypted_attributes_changed?' do
        let(:dummy_record) { DummyModel.new }
        subject { dummy_record.encrypted_attributes_changed? }

        context 'without any changes' do
          it { is_expected.to be false }
        end

        context 'with one encrypted attribute changed' do
          before { dummy_record.name = 'changed' }
          it { is_expected.to be true }
        end

        context 'with two encrypted attribute changed' do
          before do
            dummy_record.name = 'changed'
            dummy_record.age = 1234
          end

          it { is_expected.to be true }
        end

        context 'with unencrypted value changed' do
          before { dummy_record.unencrypted_value = 'changed' }
          it { is_expected.to be false }
        end

        context 'with encryption_key_id changed' do
          before { dummy_record.encryption_key_id = -1 }
          it { is_expected.to be false }
        end

        context 'with encrypted_store column changed' do
          before { dummy_record.encrypted_store = 'changed' }
          it { is_expected.to be false }
        end
      end # #encrypted_attributes_changed?

      describe '#save!' do
        subject { dummy_record.tap { |x| x.save! } }

        let(:initial_attributes) {
          { name: 'Joe', age: 12, unencrypted_value: 'value' }
        }

        context 'with new record' do
          let(:dummy_record) { DummyModel.new(initial_attributes) }

          it 'should persist values' do
            is_expected.to have_attributes(
              name: 'Joe',
              age: 12,
              unencrypted_value: 'value',
              persisted?: true,
              changes: {},
              changed?: false
            )
          end

          context 'without iteration_magnitude config' do
            it 'should use a magnitude of -1' do
              # 255 is -1 as a signed byte.
              expect(subject.encrypted_store.bytes[2]).to eq 255
            end
          end # without iteration_magnitude config

          context 'with iteration_magnitude config set' do
            let(:iter_mag) { 2 }

            before { EncryptedStore.config.iteration_magnitude = iter_mag }
            after { EncryptedStore.config.iteration_magnitude = nil }

            it "should use the configured magnitude" do
              expect(subject.encrypted_store.bytes[2]).to eq iter_mag
            end
          end # with iteration_magnitude config set
        end # with new record

        context 'with pre-existing record' do
          let(:dummy_record) { DummyModel.last }
          before { DummyModel.create!(initial_attributes) }

          let(:changed_attributes) {
            { name: 'Bob', age: 20, unencrypted_value: 'changed' }
          }

          before { dummy_record.assign_attributes(changed_attributes) }

          it 'should persist changes' do
            is_expected.to have_attributes(
              name: 'Bob',
              age: 20,
              unencrypted_value: 'changed',
              persisted?: true,
              changes: {},
              changed?: false
            )
          end

          it 'should use new encryption_key_id if it changed since loading' do
            new_key = EncryptionKey.new_key
            DummyModel.last.reencrypt(new_key)
            is_expected.to have_attributes(
              name: 'Bob',
              age: 20,
              unencrypted_value: 'changed',
              persisted?: true,
              changes: {},
              changed?: false,
              encryption_key_id: new_key.id
            )
          end
        end # with pre-existing record
      end # #save!

      describe '#reencrypt', :reencrypt do
        let(:dummy_record) { DummyModel.new }

        before do
          dummy_record.age = 5
          dummy_record.name = "joe"
          dummy_record.save!
        end

        let(:new_key) { EncryptionKey.new_key }
        subject { dummy_record.reencrypt(new_key) }

        it 'should persist record with new key' do
          subject
          expect(dummy_record.reload).to have_attributes(
            encryption_key_id: new_key.id, age: 5, name: 'joe'
          )
        end

        context 'with record changed since initial load' do
          before do
            DummyModel.find(dummy_record.id).update_attributes(
              name: 'changed',
              unencrypted_value: 'changed'
            )
          end

          it 'should reload record before re-encrypting' do
            subject
            expect(dummy_record.reload).to have_attributes(
              age: 5, name: 'changed', unencrypted_value: 'changed'
            )
          end
        end # with record changed since initial load
      end # #reencrypt

      describe '#purge_encrypted_data' do
        let(:dummy_record) { DummyModel.new }

        subject { dummy_record.purge_encrypted_data }

        before do
          dummy_record.age = 5
          dummy_record.name = "joe"
          dummy_record.unencrypted_value = "test"
          dummy_record.save!

          subject
        end

        it 'should purge the encrypted_store column' do
          expect(dummy_record.encrypted_store).to be nil
        end

        it 'should purge the encrypted_key_id column' do
          expect(dummy_record.encryption_key_id).to be nil
        end

        it 'should not have any data cached in crypto_hash' do
          expect(dummy_record.send(:_crypto_hash)).to eq({})
        end

        it 'should not delete non-encrypted data' do
          expect(dummy_record.unencrypted_value).to eq "test"
        end
      end # #purge_encrypted_data
    end # Mixin
  end # ActiveRecord
end # EncryptedStore
