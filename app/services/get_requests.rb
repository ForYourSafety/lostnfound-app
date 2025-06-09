# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a list of requests to me
  class GetRequests
    def initialize(config)
      @config = config
    end

    def call(current_account:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      response = request.get("#{@config.API_URL}/requests")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
