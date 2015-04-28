require 'rake'
Dummy::Application.load_tasks

module Ribbon::EncryptedStore
  RSpec.describe Railtie do
    describe 'new_key' do
      it 'should be defined' do
        expect(Rake::Task['encrypted_store:new_key']).to be_a Rake::Task
      end

      it 'should create a new key with the rake task' do
        expect { Rake::Task['encrypted_store:new_key'].execute }
          .to output(/^Created new primary key: \d*$/i).to_stdout
      end
    end # new_key

    describe 'retire_keys' do
      it 'should be defined' do
        expect(Rake::Task['encrypted_store:retire_keys']).to be_a Rake::Task
      end

      it 'should retire keys with the rake task' do
        expect { Rake::Task['encrypted_store:retire_keys'].execute(key_ids: '1 2 3') }
          .to output(/^^Retired key_ids: \[("\d*"(,|)( )?)*] and reencrypted records with primary key: \d*$/i).to_stdout
      end
    end # retire_keys

    describe 'rotate_keys' do
      it 'should be defined' do
        expect(Rake::Task['encrypted_store:rotate_keys']).to be_a Rake::Task
      end

      it 'should rotate keys with the rake task' do
        expect { Rake::Task['encrypted_store:rotate_keys'].execute }
          .to output(/^Retired all key_ids and reencrypted records with new primary key: \d*$/i).to_stdout
      end
    end # rotate_keys
  end # Railtie
end # Ribbon::EncryptedStore