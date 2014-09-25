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
        user = raw_info["user"]
        {
          name: [user["first_name"], user["last_name"]].compact.join(' ').strip,
          username: user["username"],
          bio: user["bio"],
          hometown: user["hometown"],
          default_location: user["default_location"],
          first_name: user["first_name"],
          last_name: user["last_name"],
          interests: user["interests"],
          images: user["images"],
          links: user["links"],
          locales: user["locales"],
          going: user["going"]
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= MultiXml.parse(access_token.get("http://api.eventful.com/rest/users/get?app_key=#{options.app_key}").body)
        if @raw_info.nil? || @raw_info["user"].nil?
          @raw_info = nil
          @raw_info = MultiXml.parse(access_token.get("http://api.eventful.com/rest/users/get?app_key=#{options.app_key}").body)
        end
        @raw_info
      end
    end
  end
end
