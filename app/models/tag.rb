# frozen_string_literal: true

module LostNFound
  # Behaviors of a tag entity
  class Tag
    attr_reader :id, :name, :description

    def initialize(tag_info)
      process_attributes(tag_info['attributes'])
    end

    private

    def process_attributes(attributes)
      @id          = attributes['id']
      @name        = attributes['name']
      @description = attributes['description']
    end
  end
end
