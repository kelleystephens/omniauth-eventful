require 'omniauth-oauth'
require "multi_xml"

module OmniAuth
  module Strategies
    class Eventful < OmniAuth::Strategies::OAuth

      args [:consumer_key, :consumer_secret, :app_key]

      option :name, "eventful"
      option :consumer_key, nil
      option :consumer_secret, nil
      option :app_key, nil

      option :client_options, {
        site: "http://api.eventful.com",
        request_token_url: "http://eventful.com/oauth/request_token",
        authorize_url: "http://eventful.com/oauth/authorize",
        access_token_url: "http://eventful.com/oauth/access_token"
      }

      uid{ info[:username] }

      info do
        name = [raw_info["user"]["first_name"], raw_info["user"]["last_name"]].compact.join(' ').strip
        {
          raw_info: raw_info,
          name: name,
          username: raw_info["user"]["username"],
          bio: raw_info["user"]["bio"],
          hometown: raw_info["user"]["hometown"],
          first_name: raw_info["user"]["first_name"],
          last_name: raw_info["user"]["last_name"],
          interests: raw_info["user"]["interests"],
          images: raw_info["user"]["images"],
          links: raw_info["user"]["links"],
          locales: raw_info["user"]["locales"],
          going: raw_info["user"]["going"]
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= MultiXml.parse(access_token.get("http://api.eventful.com/rest/users/get?app_key=#{options.app_key}&oath_consumer_key=#{options.consumer_key}").body)
      end
    end
  end
end
