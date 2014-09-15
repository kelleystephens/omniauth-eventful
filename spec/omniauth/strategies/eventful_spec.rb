require 'spec_helper'

describe "OmniAuth::Strategies::Eventful" do
  class Eventful < OmniAuth::Strategies::OAuth
    uid{ access_token.token }
    info{ {'name' => access_token.token} }
  end

  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider Eventful, 'abc', 'def', :client_options => {:site => 'https://api.eventful.com'}, :name => 'eventful.com'
        provider Eventful, 'abc', 'def', :client_options => {:site => 'https://api.eventful.com'}, :authorize_params => {:abc => 'def'}, :name => 'eventful.com_with_authorize_params'
        provider Eventful, 'abc', 'def', :client_options => {:site => 'https://api.eventful.com'}, :request_params => {:scope => 'http://foobar.eventful.com'}, :name => 'eventful.com_with_request_params'
      end
      run lambda { |env| [404, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end

  before do
    stub_request(:post, 'https://api.eventful.com/oauth/request_token').
       to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret&oauth_callback_confirmed=true")
  end

  describe '/auth/{name}' do
    context 'successful' do
      before do
        get '/auth/eventful.com'
      end

      it 'should redirect to authorize_url' do
        last_response.should be_redirect
        last_response.headers['Location'].should == 'https://api.eventful.com/oauth/authorize?oauth_token=yourtoken'
      end

      it 'should redirect to authorize_url with authorize_params when set' do
        get '/auth/eventful.com_with_authorize_params'
        last_response.should be_redirect
        [
          'https://api.eventful.com/oauth/authorize?abc=def&oauth_token=yourtoken',
          'https://api.eventful.com/oauth/authorize?oauth_token=yourtoken&abc=def'
        ].should be_include(last_response.headers['Location'])
      end

      it 'should set appropriate session variables' do
        session['oauth'].should == {"eventful.com" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}
      end

      it 'should pass request_params to get_request_token' do
        get '/auth/eventful.com_with_request_params'
        WebMock.should have_requested(:post, 'https://api.eventful.com/oauth/request_token').
           with {|req| req.body == "scope=http%3A%2F%2Ffoobar.eventful.com" }
      end
    end

    context 'unsuccessful' do
      before do
        stub_request(:post, 'https://api.eventful.com/oauth/request_token').
           to_raise(::Net::HTTPFatalError.new(%Q{502 "Bad Gateway"}, nil))
        get '/auth/eventful.com'
      end

      it 'should call fail! with :service_unavailable' do
        last_request.env['omniauth.error'].should be_kind_of(::Net::HTTPFatalError)
        last_request.env['omniauth.error.type'] = :service_unavailable
      end

      context "SSL failure" do
        before do
          stub_request(:post, 'https://api.eventful.com/oauth/request_token').
             to_raise(::OpenSSL::SSL::SSLError.new("SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed"))
          get '/auth/eventful.com'
        end

        it 'should call fail! with :service_unavailable' do
          last_request.env['omniauth.error'].should be_kind_of(::OpenSSL::SSL::SSLError)
          last_request.env['omniauth.error.type'] = :service_unavailable
        end
      end
    end
  end

    describe '/auth/{name}/callback' do
      before do
        stub_request(:post, 'https://api.eventful.com/oauth/access_token').
         to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret")
      get '/auth/eventful.com/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {'oauth' => {"eventful.com" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}}}
    end

    it 'should exchange the request token for an access token' do
      last_request.env['omniauth.auth']['provider'].should == 'eventful.com'
      last_request.env['omniauth.auth']['extra']['access_token'].should be_kind_of(OAuth::AccessToken)
    end

    it 'should call through to the master app' do
      last_response.body.should == 'true'
    end

    context "bad gateway (or any 5xx) for access_token" do
      before do
        stub_request(:post, 'https://api.eventful.com/oauth/access_token').
           to_raise(::Net::HTTPFatalError.new(%Q{502 "Bad Gateway"}, nil))
        get '/auth/eventful.com/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {'oauth' => {"eventful.com" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}}}
      end

      it 'should call fail! with :service_unavailable' do
        last_request.env['omniauth.error'].should be_kind_of(::Net::HTTPFatalError)
        last_request.env['omniauth.error.type'] = :service_unavailable
      end
    end

    context "SSL failure" do
      before do
        stub_request(:post, 'https://api.eventful.com/oauth/access_token').
           to_raise(::OpenSSL::SSL::SSLError.new("SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed"))
        get '/auth/eventful.com/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {'oauth' => {"eventful.com" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}}}
      end

      it 'should call fail! with :service_unavailable' do
        last_request.env['omniauth.error'].should be_kind_of(::OpenSSL::SSL::SSLError)
        last_request.env['omniauth.error.type'] = :service_unavailable
      end
    end
  end

  describe '/auth/{name}/callback with expired session' do
    before do
      stub_request(:post, 'https://api.eventful.com/oauth/access_token').
         to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret")
      get '/auth/eventful.com/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {}}
    end

    it 'should call fail! with :session_expired' do
      last_request.env['omniauth.error'].should be_kind_of(::OmniAuth::NoSessionError)
      last_request.env['omniauth.error.type'] = :session_expired
    end
  end
end
