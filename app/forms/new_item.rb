# frozen_string_literal: true

require_relative 'form_base'

module LostNFound
  module Form
    # This form is used to validate items.
    class NewItem < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_item.yml')

      params do
        required(:type).filled(:string)
        required(:name).filled(:string)
        optional(:contact_type).filled(:array)
        optional(:contact_value).filled(:array)
        optional(:description).maybe(:string)
        optional(:location).maybe(:string)
        optional(:challenge_question).maybe(:string)
        optional(:tags).maybe(:array)
        optional(:images).maybe(:array)
      end

      rule(:type) do
        allowed_types = %w[lost found]
        key.failure(:type_valid?) unless allowed_types.include?(value)
      end

      rule(:tags) do
        next if value.nil? || value.empty?

        key.failure(:tags_valid?) unless value.all? do |tag|
          tag.is_a?(String) && !tag.strip.empty? && tag.to_i.to_s == tag.strip
        end
      end

      rule(:contact_type) do
        key.failure(:missing?) if value.nil? || value.empty?

        allowed_types = %w[email phone address facebook twitter instagram whatsapp telegram line signal wechat discord
                           other]
        key.failure(:contact_type_valid?) unless value.all? { |type| allowed_types.include?(type) }
      end

      rule(:contact_value) do
        key.failure(:missing?) if value.nil? || value.empty?
        key.failure(:contact_value_valid?) unless value.all? { |val| val.is_a?(String) && !val.strip.empty? }
      end
    end
  end
end
