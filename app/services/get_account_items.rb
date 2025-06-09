# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a list of items made by me
  class GetAccountItems
    def initialize(config)
      @config = config
    end

    def call(current_account:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      response = request.get("#{@config.API_URL}/accounts/#{current_account.username}/items")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
