# frozen_string_literal: true

require 'roda'

module LostNFound
  # Web controller for LostnFound API
  class App < Roda
    route('items') do |routing|
      routing.on do
        # Get /items/:item_id
        routing.get String do |item_id|
          item_json = GetItem.new(App.config).call(
            current_account: @current_account,
            item_id: item_id
          )

          routing.halt(404) if item_json.nil?

          item = Item.new(item_json)

          view :item,
               locals: { current_user: @current_account, item: item }
        end

        # GET /items/
        routing.get do
          item_list = GetAllItems.new(App.config).call(@current_account)

          items = Items.new(item_list)

          view :item_all,
               locals: { current_user: @current_account, items: }
        end
      end
    end
  end
end
