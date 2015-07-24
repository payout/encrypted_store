# ribbon-encrypted_store
We use this gem for encrypting all of our sensitive data at Ribbon. This includes cardholder data and meets the necessary requirements for PCI DSS 3.0.

## Installation
Add the gem to your `Gemfile`.
```ruby
gem 'ribbon-encrypted-store', '~> 0.1.0'
```

Add the necessary initializer and migrations to your Rails app.
```
$ rails g ribbon:encrypted_store:install
```

Run the new database migrations. This will add the `encryption_keys` and `encryption_key_salts` tables.
```
$ rake db:migrate
```

## Configuration
