$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ribbon/encrypted_store/version"

Gem::Specification.new do |s|
  s.name        = 'ribbon-encrypted_store'
  s.version     = Ribbon::EncryptedStore::VERSION
  s.homepage    = "http://github.com/ribbon/encrypted_store"
  s.license     = 'BSD'
  s.summary     = "do somthing cool"
  s.description = s.summary
  s.authors     = ["Robert Honer", "Kayvon Ghaffari"]
  s.email       = ['robert@ribbonpayments.com', 'kayvon@ribbonpayments.com']
  s.files       = Dir['lib/**/*.rb'] + Dir['lib/tasks/**/*.rake']

  s.add_dependency 'bcrypt', '~> 3.1.3', '>= 3.1.3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rails', '~> 4.0.0'
end