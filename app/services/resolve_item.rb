# frozen_string_literal: true

require 'http'

module LostNFound
  # Resolves an item
  class ResolveItem
    def initialize(config)
      @config = config
    end

    def call(current_account:, item_id:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      merge_patch = {
        resolved: 1
      }

      response = request.patch("#{@config.API_URL}/items/#{item_id}", json: merge_patch)

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
