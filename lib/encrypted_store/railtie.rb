require 'encrypted_store'
require 'rails'
require 'rails/generators'

module EncryptedStore
  class Railtie < Rails::Railtie
    railtie_name :encrypted_store

    rake_tasks do
      Dir[
        File.expand_path("../../tasks", __FILE__) + '/**/*.rake'
      ].each { |rake_file| load rake_file }
    end

    generators do
      Dir[
        File.expand_path("../../generators", __FILE__) + '/**/*.rb'
      ].each { |generator| require generator }
    end
  end # Railtie
end # EncryptedStore
