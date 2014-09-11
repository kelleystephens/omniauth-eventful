require 'spec_helper'
require 'pry'

describe OmniAuth::Strategies::Eventful do
  let(:access_token) { double('AccessToken', :options => {}) }
  let(:parsed_response) { double('ParsedResponse') }
  let(:response) { double('Response', :parsed => parsed_response) }

  subject do
    OmniAuth::Strategies::Eventful.new({})
  end

  before(:each) do
    allow(subject).to receive(:access_token) { access_token }
  end

  context "client options" do
    it 'should have correct site' do
      subject.options.client_options.site.should eq("http://api.eventful.com")
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('http://eventful.com/oauth/authorize')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('http://eventful.com/oauth/request_token')
    end
  end

  context "#raw_info" do
    it "should use relative paths" do
      access_token.should_receive(:get).with('user').and_return(response)
      subject.raw_info.should eq(parsed_response)
    end
  end
end
