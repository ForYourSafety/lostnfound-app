# frozen_string_literal: true

require_relative 'item'

module LostNFound
  # Collection of item entities
  class Items
    attr_reader :all

    def initialize(items_list)
      @all = items_list.map do |item_info|
        Item.new(item_info)
      end
    end
  end
end
