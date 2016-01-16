![Boulangerie](https://raw.githubusercontent.com/cryptosphere/boulangerie/master/boulangerie.png)
for Rails!
==========
[![Gem Version](https://badge.fury.io/rb/boulangerie-rails.svg)](http://rubygems.org/gems/boulangerie-rails)
[![Build Status](https://travis-ci.org/cryptosphere/boulangerie-rails.svg)](https://travis-ci.org/cryptosphere/boulangerie-rails)
[![Code Climate](https://codeclimate.com/github/cryptosphere/boulangerie-rails/badges/gpa.svg)](https://codeclimate.com/github/cryptosphere/boulangerie-rails)
[![Coverage Status](https://coveralls.io/repos/cryptosphere/boulangerie-rails/badge.svg?branch=master&service=github)](https://coveralls.io/github/cryptosphere/boulangerie-rails?branch=master)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/cryptosphere/boulangerie-rails/master/LICENSE.txt)

[Boulangerie] is a Ruby gem for building authorization systems using
[Macaroons](http://macaroons.io), a better kind of cookie.

[Boulangerie]: https://github.com/cryptosphere/boulangerie

## Installation

boulangerie-rails can be used with Rails 4.1+.

Add this line to your application's Gemfile:

```ruby
gem 'boulangerie-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boulangerie-rails

## Usage

Add the following to `config/initializers/boulangerie.rb`:

```ruby
Boulangerie.setup(
  schema:   Rails.root.join("config/boulangerie_schema.yml"),
  keys:     Rails.application.secrets.boulangerie_keys
  key_id:   "key1"
  location: "https://mycoolsite.com"
)
```

You will also need to edit `config/secrets.yml` and add the following to
your respective environments (example given for development):

```yaml
development:
  secret_key_base: DEADBEEFDEADBEEFDEADBEEF[...]
  boulangerie_keys:
    key0: "1b942ba242e9d39ce838d03652091695eb1fef93d35d9454498ca970a8827e8f"
    key1: "7efc8f72d159ce31a4b2c8db6281bf8d91a2f2778d4d0062f80b977ea43a8ec4"
```

The `boulangerie_keys` hash contains a "keyring" of keys which can be used to
create or verify Macaroons.

To generate random keys, use the `Boulangerie::Keyring.generate_key` method,
which you can call from `irb` or `pry`:

```
[1] pry(main)> require 'boulangerie'
=> true
[2] pry(main)> Boulangerie::Keyring.generate_key
=> "1b942ba242e9d39ce838d03652091695eb1fef93d35d9454498ca970a8827e8f"
```

The names of the keys (e.g. `key0`, `key1`) are arbitrary, but all new Macaroons
will use the key whose ID was passed in as the `key_id` option to
`Boulangerie#initialize`. This allows for key rotation, i.e. periodically you can
add a new key, and Macaroons minted under an old key will still verify.

Rotating keys is good security practice and you should definitely take advantage of it.

You'll also need to create a `config/boulangerie_schema.yml` file that
contains the schema for your Macaroons. Here is a basic schema that will
add `not-before` and `expires` timestamp assertions on your Macaroons:

```yaml
---
schema-id: ee6da70e5ba01fec
predicates:
  v0:
    not-before: DateTime
    expires: DateTime
```

A `schema-id` is a 64-bit random number. This is used to identify a schema
uniquely within your system regardless of what you decide to name or rename
the schema file.

You can generate a schema ID via `irb` or `pry`:

```
[1] pry(main)> require 'boulangerie'
=> true
[2] pry(main)> Boulangerie::Schema.create_schema_id
=> "ee6da70e5ba01fec"
```

A schema-id can also be any 64-bit random number serialized as hex which
is unique to your app/infrastructure.

This schema includes two *caveats*: an expiration date and a creation time,
before which the Macaroon is not considered valid.
The predicate matchers for these particular caveats are built into
Boulangerie, but you can extend it with your own.

To create a Macaroon, we'll need to call the `#bake` method. The following
will create a new Macaroon and set it as the "my_macaroon" cookie:

```ruby
class AuthenticationController < ApplicationController
  # Perform some kind of authentication ritual here
  before_action :check_credentials, :only => :authenticate

  def authenticate
    expires_at = 24.hours.from_now

    cookie = Boulangerie.bake(caveats: {
      expires:    Time.now,
      not_before: expires_at
    })

    cookies[:my_macaroon] = {
      value:    cookie,
      expires:  expires_at,
      secure:   true,
      httponly: true
    }
  end
```

Finally, to actually use Macaroons to make authorization decisions, we need
to configure Boulangerie in a given controller:

```ruby
class MyController < ApplicationController
  authorize_with_boulangerie :cookie => :my_macaroon
end
```

## Supported Ruby Versions

This library supports and is tested against the following Ruby versions:

* Ruby (MRI) 2.0, 2.1, 2.2, 2.3
* JRuby 9000

## Contributing

* Fork this repository on GitHub
* Make your changes and send us a pull request
* If we like them we'll merge them
* If we've accepted a patch, feel free to ask for commit access

## License

Copyright (c) 2016 Tony Arcieri. Distributed under the MIT License.
See LICENSE.txt for further details.