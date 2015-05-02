require 'rake'
require 'rails/generators'
Dummy::Application.load_tasks
Dummy::Application.load_generators

module Ribbon::EncryptedStore
  RSpec.describe Railtie do
    describe 'rake_tasks' do
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
            .to output(/^Retired key_ids: \[("\d*"(,|)( )?)*\] and reencrypted records with primary key: \d*$/i).to_stdout
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
    end # rake_tasks

    describe 'generators', :type => :generator do
      describe 'install_encrypted_store' do
        it 'should be defined' do
          expect(Rails::Generators.subclasses).to include InstallEncryptedStoreGenerator
        end
      end # install_encrypted_store

      describe 'encrypt_table' do
        it 'should be defined' do
          expect(Rails::Generators.subclasses).to include EncryptTableGenerator
        end
      end # encrypt_table
    end # generators
  end # Railtie
end # Ribbon::EncryptedStore

+  # This is displayed when users are on mobile
+  def _generate_fallback(type)
+    return 'Monthly tokenizations trend' if type == :tokenizations
+    return 'Monthly credits trend' if type == :credits
+    return 'Monthly credit failure rate trend' if type == :credit_failure_rate
+    return 'Monthly card coverage trend' if type == :card_coverage
+  end

def _generate_fallback(type)
  case type
end