# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate items.
    class NewItem < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_item.yml')

      params do
        required(:type).filled(:integer)
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        optional(:location).maybe(:string)
        optional(:person_info).maybe(:string)
      end

      rule(:type) do
        allowed_types = [0, 1] # 0: lost, 1: found
        key.failure(:type_valid?) unless allowed_types.include?(value)
      end
    end
  end
end
