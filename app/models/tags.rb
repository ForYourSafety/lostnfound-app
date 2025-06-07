# frozen_string_literal: true

require_relative 'item'

module LostNFound
  # Collection of item entities
  class Tags
    attr_reader :all

    def initialize(tags_list)
      @all = tags_list.map do |tag_info|
        Tag.new(tag_info)
      end
    end
  end
end
