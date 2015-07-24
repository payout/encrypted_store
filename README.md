# ribbon-encrypted_store
A gem for encrypting data securily in a Ruby app.

## Installation
Add the gem to your `Gemfile`.
```ruby
gem `ribbon-encrypted-store`, '~> 0.1.0'
```

Add the necessary initializer and migrations to your Rails app.
```
$ rails g ribbon:encrypted_store:install
```

Run the new database migrations. This will add the `encryption_keys` and `encryption_key_salts` tables.
```
$ rake db:migrate
```
