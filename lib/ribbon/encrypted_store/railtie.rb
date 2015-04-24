require 'ribbon/encrypted_store'
require 'rails'

module Ribbon
  module EncryptedStore
    class Railtie < Rails::Railtie
      railtie_name :encrypted_store

      rake_tasks do
        Dir[
          File.expand_path("../../../tasks", __FILE__) + '/**/*.rake'
        ].each { |rake_file| load rake_file }
      end
    end # Railtie
  end # EncryptedStore
end # Ribbon