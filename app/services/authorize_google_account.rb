# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns an authenticated user, or nil
  class AuthorizeGoogleAccount
    # Errors emanating from Github
    class UnauthorizedError < StandardError
      def message
        'Could not login with Google'
      end
    end

    def initialize(config)
      @config = config
    end

    def call(code)
      access_token = get_access_token_from_google(code)
      get_sso_account_from_api(access_token)
    end

    private

    def get_access_token_from_google(code)
      challenge_response =
        HTTP.headers(accept: 'application/json',
                     content_type: 'application/x-www-form-urlencoded')
            .post(@config.GO_TOKEN_URL,
                  form: { code: code,
                          client_id: @config.GO_CLIENT_ID,
                          client_secret: @config.GO_CLIENT_SECRET,
                          redirect_uri: @config.GO_REDIRECT_URI,
                          grant_type: 'authorization_code' })
      raise UnauthorizedError unless challenge_response.status < 400

      JSON.parse(challenge_response)['access_token']
    end

    def get_sso_account_from_api(access_token)
      response =
        HTTP.post("#{@config.API_URL}/auth/sso",
                  json: { access_token: access_token })
      raise if response.code >= 400

      account_info = JSON.parse(response)['data']['attributes']

      {
        account: account_info['account'],
        auth_token: account_info['auth_token']
      }
    end
  end
end
