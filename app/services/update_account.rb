# frozen_string_literal: true

require 'http'

module LostNFound
  class UpdateAccount # rubocop:disable Style/Documentation
    def initialize(config)
      @config = config
    end

    def call(current_account:, account_params:)
      account_data = {
        student_id: account_params[:student_id],
        name_on_id: account_params[:name_on_id]
      }

      account_data[:password] = account_params[:password] if account_params[:password]

      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put("#{@config.API_URL}/accounts/#{current_account.username}",
                          json: account_data)

      response.code == 200 ? JSON.parse(response.to_s)['data'] : nil
    end
  end
end
