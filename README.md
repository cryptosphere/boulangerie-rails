![Boulangerie](https://raw.githubusercontent.com/cryptosphere/boulangerie-rails/master/boulangerie-rails.png)
======================
[![Gem Version](https://badge.fury.io/rb/boulangerie-rails.svg)](http://rubygems.org/gems/boulangerie-rails)
[![Build Status](https://travis-ci.org/cryptosphere/boulangerie-rails.svg)](https://travis-ci.org/cryptosphere/boulangerie-rails)
[![Code Climate](https://codeclimate.com/github/cryptosphere/boulangerie-rails/badges/gpa.svg)](https://codeclimate.com/github/cryptosphere/boulangerie-rails)
[![Coverage Status](https://coveralls.io/repos/cryptosphere/boulangerie-rails/badge.svg?branch=master&service=github)](https://coveralls.io/github/cryptosphere/boulangerie-rails?branch=master)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/cryptosphere/boulangerie-rails/master/LICENSE.txt)

[Boulangerie] is a Ruby gem for building authorization systems using
[Macaroons](http://macaroons.io), a better kind of cookie.

This gem contains support for using Boulangerie with Ruby on Rails.

[Boulangerie]: https://github.com/cryptosphere/boulangerie

## Installation

boulangerie-rails can be used with Rails 4.1+.

Add this line to your application's Gemfile:

```ruby
gem "boulangerie-rails"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boulangerie-rails

## Usage

Add the following to `config/initializers/boulangerie.rb`:

```ruby
keyring = Boulangerie::Keyring.new(
  keys:   Rails.application.secrets.boulangerie.keys,
  key_id: Rails.application.secrets.boulangerie.default_key_id
)

Boulangerie.setup(
  id:       :photos,
  schema:   Rails.root.join("config/boulangerie/photos_schema.yml"),
  keyring:  keyring,
  location: "https://mycoolsite.com/photos"
)
```

You will also need to edit `config/secrets.yml` and add the following to
your respective environments (example given for development):

```yaml
development:
  secret_key_base: DEADBEEFDEADBEEFDEADBEEF[...]
  boulangerie:
    default_key_id: k1
    keyring:
      k0: "1b942ba242e9d39ce838d03652091695eb1fef93d35d9454498ca970a8827e8f"
      k1: "7efc8f72d159ce31a4b2c8db6281bf8d91a2f2778d4d0062f80b977ea43a8ec4"
```

The `keyring` hash contains all of the currently active keys which are allowed
to verify Macaroons. The `default_key_id` is used to create new Macaroons.
The names of the keys (e.g. `k0`, `k1`) are arbitrary.

This allows for key rotation, i.e. periodically you can add a new key, and
Macaroons minted under an old key will still verify. Rotating keys is good
security practice and you should definitely take advantage of it.

To generate random keys, use the `Boulangerie::Keyring.generate_key` method,
which you can call from `irb` or `pry`:

```
[1] pry(main)> require "boulangerie"
=> true
[2] pry(main)> Boulangerie::Keyring.generate_key
=> "1b942ba242e9d39ce838d03652091695eb1fef93d35d9454498ca970a8827e8f"
```

*NOTE: Do not use this key (i.e. `1b942b`)! Make your own!*

You'll also need to create schema files for the domain objects you intend to
restrict access to via Macaroons, e.g. `config/boulangerie/photos_schema.yml`.

Here is a basic schema that will add `not-before` and `expires` timestamp
assertions on your Macaroons:

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

    macaroon = Boulangerie.create_macaroon(
      caveats: {
        expires:    Time.now,
        not_before: expires_at
      }
    )

    cookies[:photos_macaroon] = macaroon.to_rails_cookie
  end
```

Finally, to actually use Macaroons to make authorization decisions, we need
to configure Boulangerie in a given controller:

```ruby
class PhotosController < ApplicationController
  authorize_with_boulangerie(
    id:       :photos,
    cookie:   :photos_macaroon
    matchers: Boulangerie::Rails::ActiveRecordMatchers.create(
      model:      Photos,
      attributes: %i(id user_id)
    )
  )
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
