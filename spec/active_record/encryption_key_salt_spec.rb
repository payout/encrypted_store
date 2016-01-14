module EncryptedStore
  module ActiveRecord
    RSpec.describe EncryptionKeySalt do
      describe '#generate_salt' do
        let(:encryption_key_id) { EncryptionKey.new_key.id }
        subject { EncryptionKeySalt.generate_salt(encryption_key_id) }

        it { is_expected.to be_a String }
        it 'should generate a new salt record' do
          expect(subject).to eq EncryptionKeySalt.last.salt
          expect(EncryptionKeySalt.last.encryption_key_id).to eq encryption_key_id
        end
      end # #generate_salt
    end # EncryptionKeySalt
  end # ActiveRecord
end # EncryptedStore
