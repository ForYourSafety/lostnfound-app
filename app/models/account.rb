# frozen_string_literal: true

module LostNFound
  # Behaviors of the currently logged in account
  class Account
    def initialize(account_info, auth_token = nil)
      @account_info = account_info
      @auth_token = auth_token
    end

    attr_reader :account_info, :auth_token

    def username
      @account_info ? @account_info['attributes']['username'] : nil
    end

    def email
      @account_info ? @account_info['attributes']['email'] : nil
    end

    def id
      @account_info ? @account_info['attributes']['id'] : nil
    end

    def student_id
      @account_info ? @account_info['attributes']['student_id'] : nil
    end

    def name_on_id
      @account_info ? @account_info['attributes']['name_on_id'] : nil
    end

    def logged_out?
      @account_info.nil?
    end

    def logged_in?
      !logged_out?
    end
  end
end
