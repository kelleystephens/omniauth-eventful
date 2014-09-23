[![Build Status](https://travis-ci.org/kelleystephens/omniauth-eventful.svg?branch=master)](https://travis-ci.org/kelleystephens/omniauth-eventful)


# Omniauth::Eventful

This gem is an OmniAuth Strategy for the Eventful API. Eventful uses OAuth 1.0,
you can read about their authentication process here:  

>[Eventful Authentication Docs](http://api.eventful.com/)

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-eventful'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-eventful

## Usage

Tell OmniAuth about this provider. For a Rails app, your config/initializers/omniauth.rb file should look like this:

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :eventful, "CONSUMER_KEY", "CONSUMER_SECRET", "APP_KEY"
    end

Replace "CONSUMER_KEY", "CONSUMER_SECRET" and "APP_KEY" with the appropriate values you obtain
from [Requesting an App Key](http://api.eventful.com/keys/new).

Make sure to set a route in your config/routes.rb file to handle the callback.
For example:

`get '/auth/:provider/callback', to: 'sessions#create'`

Then, access the returned data in your Sessions Controller.
For example:

`omniauth_hash = request.env['omniauth.auth'].to_hash`<br>
`name = omniauth['info']['name']`

See an example of the Auth Hash available in request.env['omniauth.auth'] at:
> [OmniAuth Auth Hash Schema](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema)

To see the output parameters for the Eventful User check out:
> [User Data](http://api.eventful.com/docs/users/get)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/omniauth-eventful/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
