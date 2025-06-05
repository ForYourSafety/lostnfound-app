# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do # rubocop:disable Metrics/BlockLength
  before do
    @credentials = { username: 'master.yi', password: 'abcdefg' }
    @mal_credentials = { username: 'master.yi', password: 'gfedcba' }
    @api_account = { attributes:
                       { username: 'master.yi', email: 'yi@nthu.edu.tw' } }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @credentials.to_json)
             .to_return(body: @api_account.to_json,
                        headers: { 'content-type' => 'application/json' })

      account = LostNFound::AuthenticateAccount.new(app.config).call(**@credentials)
      _(account).wont_be_nil
      _(account['username']).must_equal @api_account[:attributes][:username]
      _(account['email']).must_equal @api_account[:attributes][:email]
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
