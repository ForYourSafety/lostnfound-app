# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do # rubocop:disable Metrics/BlockLength
  before do
    @credentials = { username: 'fifiding', password: 'sweetdreamsaremadeofcheese123' }
    @mal_credentials = { username: 'fifiding', password: 'wrongpassword' }
    @api_account = { attributes:
                       { username: 'fifiding', email: 'fifi.ding@iss.nthu.edu.tw' } }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      auth_account_file = 'spec/fixtures/auth_account.json'
      ## Use this code to get an actual seeded account from API:
      # @credentials = { username: 'fifiding', password: 'sweetdreamsaremadeofcheese123' }
      # signed_payload = SignedMessage.sign(@credentials)
      # WebMock.disable!
      # response = HTTP.post("#{app.config.API_URL}/auth/authenticate",
      #                      json: signed_payload)

      # auth_account_json = response.body.to_s
      # File.write(auth_account_file, auth_account_json)
      auth_return_json = File.read(auth_account_file)

      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: SignedMessage.sign(@credentials))
             .to_return(body: auth_return_json,
                        headers: { 'content-type' => 'application/json' })

      auth = LostNFound::AuthenticateAccount.new.call(**@credentials)

      _(auth).wont_be_nil
      _(auth[:account]['attributes']['username']).must_equal @api_account[:attributes][:username]
      _(auth[:account]['attributes']['email']).must_equal @api_account[:attributes][:email]
    end

    it 'BAD: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: SignedMessage.sign(@mal_credentials).to_json)
             .to_return(status: 401)
      _(proc {
        LostNFound::AuthenticateAccount.new.call(**@mal_credentials)
      }).must_raise LostNFound::AuthenticateAccount::NotAuthenticatedError
    end
  end
end
