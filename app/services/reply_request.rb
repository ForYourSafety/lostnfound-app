# frozen_string_literal: true

require 'http'

module LostNFound
  # Replies to a request
  class ReplyRequest
    def initialize(config)
      @config = config
    end

    def call(current_account:, request_id:, status:)
      request = HTTP.auth("Bearer #{current_account.auth_token}")

      merge_patch = {
        status:
      }

      response = request.patch("#{@config.API_URL}/requests/#{request_id}", json: merge_patch)

      puts merge_patch.to_json
      puts "ReplyRequest response: #{response}"

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
