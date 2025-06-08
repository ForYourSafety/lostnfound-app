# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a single item
  class DeleteItem
    def initialize(config)
      @config = config
    end

    def call(current_account:, item_id:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      response = request.delete("#{@config.API_URL}/items/#{item_id}")

      response.code == 204
    end
  end
end
