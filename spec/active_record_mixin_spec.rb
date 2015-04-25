module Ribbon::EncryptedStore
  module Mixins
    RSpec.describe ActiveRecordMixin do
      describe '#attr_encrypted' do
      end

      describe 'saving' do
        let(:dummy_record) { DummyModel.new }
        before {
          dummy_record.name = "test"
          dummy_record.age = 12
          dummy_record.save
          puts dummy_record.inspect
        }
        subject { dummy_record }

        context 'with attributes changed' do
          before {
            dummy_record.age = 13
            dummy_record.save
          }
          it { is_expected.to eq DummyRecord.last }
          it 'should have all of the fields set' do

          end
        end

        context 'without attributes changed' do

        end
      end
    end # ActiveRecordMixin
  end # Mixins
end # Ribbon::EncryptedStore