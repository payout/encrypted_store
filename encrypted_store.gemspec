$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "encrypted_store/version"

Gem::Specification.new do |s|
  s.name        = 'encrypted_store'
  s.version     = EncryptedStore::VERSION
  s.homepage    = "http://github.com/payout/encrypted_store"
  s.license     = 'BSD'
  s.summary     = "Provides the EncryptedStore mixin"
  s.description = s.summary
  s.authors     = ["Robert Honer", "Kayvon Ghaffari"]
  s.email       = ['robert@payout.com', 'kayvon@payout.com']
  s.files       = Dir['lib/**/*.rb'] + Dir['lib/tasks/**/*.rake'] + Dir['lib/generators/**/*.rb']

  s.add_dependency 'bcrypt', '~> 3.1.3', '>= 3.1.3'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rails', '~> 4.0.0'
end
