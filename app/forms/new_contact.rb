# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate contact
    class NewContact < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_contact.yml')

      params do
        required(:contact_type).filled(:integer)
        required(:value).filled(:string)
      end

      rule(:contact_type) do
        allowed_types = (0..12).to_a
        key.failure(:contact_type_valid?) unless allowed_types.include?(value)
      end

      rule(:value) do
        # Optional: Basic format check, e.g., length or character restriction
        key.failure(:value_valid?) if value.strip.empty?
      end
    end
  end
end
