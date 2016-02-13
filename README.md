[![Gem Version](https://badge.fury.io/rb/encrypted_store.svg)](https://badge.fury.io/rb/encrypted_store) [![Build Status](https://travis-ci.org/payout/encrypted_store.svg?branch=master)](https://travis-ci.org/payout/encrypted_store) [![Code Climate](https://codeclimate.com/github/payout/encrypted_store/badges/gpa.svg)](https://codeclimate.com/github/payout/encrypted_store) [![Test Coverage](https://codeclimate.com/github/payout/encrypted_store/badges/coverage.svg)](https://codeclimate.com/github/payout/encrypted_store/coverage)

# encrypted_store
We use this gem for encrypting all of our sensitive data at Payout.com.

## Installation
Add the gem to your `Gemfile`.
```ruby
gem 'encrypted-store', '~> 0.2.0'
```

Add the necessary initializer and migrations to your Rails app.
```
$ rails g encrypted_store:install
```

Run the new database migrations. This will add the `encryption_keys` and `encryption_key_salts` tables.
```
$ rake db:migrate
```

## Configuration
