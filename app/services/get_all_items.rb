# frozen_string_literal: true

require 'http'

module LostNFound
  # Returns all items
  class GetAllItems
    def initialize(config)
      @config = config
    end

    def call(current_account)
      request = HTTP
      request = HTTP.auth("Bearer #{current_account.auth_token}") if current_account.logged_in?

      response = request.get("#{@config.API_URL}/items")

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
