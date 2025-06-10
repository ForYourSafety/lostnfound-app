# frozen_string_literal: true

require 'http'

module LostNFound
  class AddStudentInfo # rubocop:disable Style/Documentation
    def initialize(config)
      @config = config
    end

    def call(current_account:, student_info_params:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{@config.API_URL}/accounts/#{current_account.username}/student_info",
                           json: student_info_params)

      return nil unless response.code == 200

      parsed = JSON.parse(response.body.to_s)
      parsed['data']
    end
  end
end
