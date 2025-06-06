# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns a single item
  class GetItem
    def initialize(config)
      @config = config
    end

    def call(current_account:, item_id:)
      request = HTTP
      request = HTTP.auth("Bearer #{current_account.auth_token}") if current_account.logged_in?

      response = request.get("#{@config.API_URL}/items/#{item_id}")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
