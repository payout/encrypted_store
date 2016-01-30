module EncryptedStore
  module ActiveRecord
    RSpec.describe EncryptionKey do
      describe '::primary_encryption_key', :primary_encryption_key do
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

        context 'without a primary set' do
          before {
            EncryptionKey.new_key
            EncryptionKey.where(primary: true).first.update_attributes(primary: false)
          }
          it { is_expected.to eq EncryptionKey.last }
        end
      end # ::primary_encryption_key

      describe '::new_key', :new_key do
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
      end # ::new_key

      describe '::retire_keys', :retire_keys do
        let(:key_ids) { [] }
        let(:dummy_record) { DummyModel.new }
        let(:dummy_record_2) { DummyModel.new }
        let(:orig_key_id) { dummy_record.encryption_key_id }
        before {
          dummy_record.name = "joe"
          dummy_record.age = 14
          dummy_record.save

          orig_key_id

          EncryptionKey.new_key
          dummy_record_2.name = "bob"
          dummy_record_2.age = 10
          dummy_record_2.save
        }

        context 'with key_ids arg' do
          before {
            new_key
            EncryptionKey.retire_keys(key_ids)
          }
          let(:new_key) { EncryptionKey.new_key }

          context 'with non-existant key_id' do
            let(:key_ids) { [dummy_record.encryption_key_id-1] }
            it 'should not retire any records' do
              expect(DummyModel.find(dummy_record.id).encryption_key_id).to eq orig_key_id
              expect(DummyModel.find(dummy_record.id).encryption_key_id).not_to eq new_key.id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).to eq dummy_record_2.encryption_key_id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).not_to eq new_key.id
            end
          end

          context 'with empty key_id array' do
            let(:key_ids) { [] }
            it 'should retire all records' do
              expect(DummyModel.find(dummy_record.id).encryption_key_id).to eq new_key.id
              expect(DummyModel.find(dummy_record.id).encryption_key_id).not_to eq orig_key_id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).to eq new_key.id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).not_to eq dummy_record_2.encryption_key_id
            end
          end

          context 'with a valid key_id' do
            let(:key_ids) { [dummy_record.encryption_key_id] }

            it 'should retire specified records' do
              expect(DummyModel.find(dummy_record.id).encryption_key_id).to eq new_key.id
              expect(DummyModel.find(dummy_record.id).encryption_key_id).not_to eq orig_key_id
            end

            it 'should not retire unspecified records' do
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).to eq dummy_record_2.encryption_key_id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).not_to eq new_key.id
            end
          end

          context 'with multiple valid key_ids' do
            let(:key_ids) { [dummy_record.encryption_key_id, dummy_record_2.encryption_key_id] }
            let(:dummy_record_3) { DummyModel.new }
            before {
              EncryptionKey.new_key
              dummy_record_3.age = 1
              dummy_record_3.name = "jim"
              dummy_record_3.save
            }

            it 'should retire all specified records' do
              expect(DummyModel.find(dummy_record.id).encryption_key_id).to eq new_key.id
              expect(DummyModel.find(dummy_record.id).encryption_key_id).not_to eq orig_key_id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).to eq new_key.id
              expect(DummyModel.find(dummy_record_2.id).encryption_key_id).not_to eq dummy_record_2.encryption_key_id
            end

            it 'should not retire unspecified records' do
              expect(DummyModel.find(dummy_record_3.id).encryption_key_id).to eq dummy_record_3.encryption_key_id
              expect(DummyModel.find(dummy_record_3.id).encryption_key_id).not_to eq new_key.id
            end
          end
        end

        context 'without key_ids arg' do
          before {
            new_key
            EncryptionKey.retire_keys(key_ids)
          }
          let(:new_key) { EncryptionKey.new_key }

          it 'should retire all specified records' do
            expect(DummyModel.find(dummy_record.id).encryption_key_id).to eq new_key.id
            expect(DummyModel.find(dummy_record.id).encryption_key_id).not_to eq orig_key_id
            expect(DummyModel.find(dummy_record_2.id).encryption_key_id).to eq new_key.id
            expect(DummyModel.find(dummy_record_2.id).encryption_key_id).not_to eq dummy_record_2.encryption_key_id
          end
        end
      end # ::retire_keys

      describe '::rotate_keys', :rotate_keys do
        subject { EncryptionKey.rotate_keys }

        before do
          5.times {
            DummyModel.create!(name: 'Joe', age: 14, unencrypted_value: 'value')
          }
        end

        let(:orig_key) { EncryptionKey.first }
        let(:new_key) { EncryptionKey.last }

        it 'should rotate all of the keys' do
          expect(DummyModel.all.map(&:encryption_key_id).uniq)
            .to eq [orig_key.id]

          subject

          expect(DummyModel.all.map(&:encryption_key_id).uniq)
            .to eq [new_key.id]
        end

        it 'should not corrupt encryption of records' do
          subject
          expect(DummyModel.all.map(&:_crypto_hash))
            .to eq [{name: 'Joe', age: 14}] * 5
        end
      end # ::rotate_keys

      describe '::preload', :preload do
        subject { EncryptionKey.preload(amount) }

        before do
          key_count.times { EncryptionKey.new_key }
        end

        let(:oldest_key) { EncryptionKey.first }

        context 'with amount 3 and 4 keys' do
          let(:amount) { 3 }
          let(:key_count) { 4 }

          it 'should return 3 keys' do
            expect(subject.count).to eq 3
          end

          it 'should not return the oldest key' do
            expect(subject.map(&:id)).not_to include(oldest_key.id)
          end
        end
      end # ::preload
    end # EncryptionKey
  end # ActiveRecord
end # EncryptedStore
