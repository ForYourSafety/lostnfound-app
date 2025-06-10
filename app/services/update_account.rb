# frozen_string_literal: true

require 'http'

module LostNFound
  class UpdateAccount # rubocop:disable Style/Documentation
    def initialize(config)
      @config = config
    end

    def call(current_account:, account_params:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put("#{@config.API_URL}/accounts/#{current_account.username}",
                          json: account_params)

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
