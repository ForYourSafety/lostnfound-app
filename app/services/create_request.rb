# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a single item
  class CreateRequest
    def initialize(config)
      @config = config
    end

    def call(current_account:, item_id:, request_params:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      response = request.post("#{@config.API_URL}/items/#{item_id}/requests", json: request_params)

      response.code == 201 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
