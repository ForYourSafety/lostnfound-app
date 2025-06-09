# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a list of requests of a specific item
  class GetItemRequests
    def initialize(config)
      @config = config
    end

    def call(current_account:, item_id:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      response = request.get("#{@config.API_URL}/items/#{item_id}/requests")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
