# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # Form for updating account information
    class UpdateAccount < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/update_account.yml')

      params do
        optional(:password).maybe(:string)
        optional(:password_confirm).maybe(:string)
        optional(:student_id).maybe(:string, min_size?: 5)
        optional(:name_on_id).maybe(:string)
      end

      def enough_entropy?(string)
        StringSecurity.entropy(string) >= 3.0
      end

      rule(:password) do
        key.failure(:password) if !value.nil? && value.strip.empty?
      end

      rule(:password_confirm) do
        key.failure(:password_confirm) if !value.nil? && value.strip.empty?
      end

      rule(:password) do
        key.failure(:password_entropy) if !value.nil? && !enough_entropy?(value)
      end

      rule(:password, :password_confirm) do
        if !values[:password].nil? && !values[:password_confirm].nil?
          key.failure(:passwords_match) unless values[:password].eql?(values[:password_confirm]) # rubocop:disable Style/SoleNestedConditional
        end
      end
    end
  end
end
