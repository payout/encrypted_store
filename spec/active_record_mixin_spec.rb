module EncryptedStore
  module Mixins
    RSpec.describe ActiveRecordMixin do
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

      describe 'saving' do
        let(:dummy_record) { DummyModel.new(name: 'test', age: 12) }
        subject { dummy_record.tap { |d| d.save! } }

        context 'with attributes changed' do
          before {
            dummy_record.age = 13
            dummy_record.save
          }

          it { is_expected.to eq DummyModel.last }
          it 'should have all of the fields set' do
            dm = DummyModel.last
            expect(dm.name).to eq dummy_record.name
            expect(dm.age).to eq dummy_record.age
          end

          context 'without calling save' do
            before { dummy_record.age = 14 }

            it 'should set the field as changed' do
              expect(dummy_record.changes).to eq({"age"=>[13, 14]})
            end

            it 'should not save encrypted_store' do
              expect(DummyModel.last.age).to eq 13
            end
          end # without calling save
        end # with attributes changed

        context 'without iteration_magnitude config' do
          it 'should use a magnitude of -1' do
            # 255 is -1 as a signed byte.
            expect(subject.encrypted_store.bytes[2]).to eq 255
          end
        end # without iteration_magnitude config

        context 'with iteration_magnitude config set' do
          let(:iter_mag) { 2 }

          before {
            EncryptedStore.config.iteration_magnitude = iter_mag
          }

          after {
            EncryptedStore.config.iteration_magnitude = nil
          }

          it "should use the configured magnitude" do
            expect(subject.encrypted_store.bytes[2]).to eq iter_mag
          end
        end # with iteration_magnitude config set
      end # saving

      describe '#reencrypt' do
        let(:dummy_record) { DummyModel.new }
        before {
          dummy_record.age = 5
          dummy_record.name = "joe"
          dummy_record.save
        }

        it 'should not save the new key with reencrypt' do
          new_key = ActiveRecordMixin::EncryptionKey.new_key
          dummy_record.reencrypt(new_key)
          expect(DummyModel.find(dummy_record).encryption_key_id).not_to eq new_key.id
          expect(DummyModel.find(dummy_record).age).to eq dummy_record.age
          expect(DummyModel.find(dummy_record).name).to eq dummy_record.name
        end

        it 'should reencrypt with the new encryption key' do
          prv_key_id = dummy_record.encryption_key_id
          new_key = ActiveRecordMixin::EncryptionKey.new_key
          dummy_record.reencrypt!(new_key)
          expect(dummy_record.encryption_key_id).to eq new_key.id
          expect(dummy_record.age).to eq 5
          expect(dummy_record.name).to eq "joe"
        end
      end # #reencrypt
    end # ActiveRecordMixin
  end # Mixins
end # EncryptedStore
