# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do
  before do
    @credentials = { username: 'sarahpan', password: '12345678a' }
    @mal_credentials = { username: 'sarahpan', password: 'gfedcba' }
    @api_account = { attributes:
                       { username: 'sarahpan', email: 'sarah.pan@iss.nthu.edu.tw' } }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      auth_account_file = 'spec/fixtures/auth_account.json'
      # Use this code to get an actual seeded account from API:
      WebMock.disable!
      response = HTTP.post("#{app.config.API_URL}/auth/authenticate",
                           json: { username: @credentials[:username], password: @credentials[:password] })

      auth_account_json = response.body.to_s
      File.write(auth_account_file, auth_account_json)
      puts "Seeded response saved to #{auth_account_file}"
      WebMock.enable!

      auth_return_json = File.read(auth_account_file)
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @credentials.to_json)
             .to_return(body: auth_return_json,
                        headers: { 'content-type' => 'application/json' })

      account = LostNFound::AuthenticateAccount.new(app.config).call(**@credentials)
      _(account).wont_be_nil
      _(account[:account]['attributes']['username']).must_equal @api_account[:attributes][:username]
      _(account[:account]['attributes']['email']).must_equal @api_account[:attributes][:email]
    end

    it 'BAD: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @mal_credentials.to_json)
             .to_return(status: 403)
      _(proc {
        LostNFound::AuthenticateAccount.new(app.config).call(**@mal_credentials)
      }).must_raise LostNFound::AuthenticateAccount::UnauthorizedError
    end
  end
end
