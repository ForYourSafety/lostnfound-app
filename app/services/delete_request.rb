# frozen_string_literal: true

require 'http'

module LostNFound
  # Deletes a single request
  class DeleteRequest
    def initialize(config)
      @config = config
    end

    def call(current_account:, request_id:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      response = request.delete("#{@config.API_URL}/requests/#{request_id}")

      response.code == 204
    end
  end
end
