# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate login credentials for authentication.
    class LoginCredentials < Dry::Validation::Contract
      params do
        required(:username).filled
        required(:password).filled
      end
    end

    # This form is used to validate registration details for a new account.
    class Registration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:username).filled(format?: USERNAME_REGEX, min_size?: 4)
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    # This form is used to validate the details for updating an account.
    class Passwords < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/password.yml')

      params do
        required(:password).filled(:string)
        required(:password_confirm).filled(:string)
      end

      def enough_entropy?(string)
        StringSecurity.entropy(string) >= 3.0
      end

      rule(:password) do
        key.failure(:password) if value.strip.empty?
      end

      rule(:password_confirm) do
        key.failure(:password_confirm) if value.strip.empty?
      end

      rule(:password) do
        key.failure(:password_entropy) unless enough_entropy?(value)
      end

      rule(:password, :password_confirm) do
        key.failure(:passwords_match) unless values[:password].eql?(values[:password_confirm])
      end
    end
  end
end
