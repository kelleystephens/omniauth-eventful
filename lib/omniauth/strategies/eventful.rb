require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Eventful
      include OmniAuth::Strategy

      option :name, "eventful"

      option :client_options, {
        site: "http://api.eventful.com",
        authorize_url: "http://eventful.com/oauth/authorize",
        token_url: "http://eventful.com/oauth/request_token"
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[scope client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      def callback_url
        options[:redirect_uri] || super
      end

      uid { raw_info["id"].to_s }

      info do
        {
          username: raw_info["user"]["username"],
          bio: raw_info["user"]["bio"],
          hometown: raw_info["user"]["hometown"],
          first_name: raw_info["user"]["first_name"],
          last_name: raw_info["user"]["last_name"],
          interests: raw_info["user"]["interests"]
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('user').parsed
      end
    end
  end
end
