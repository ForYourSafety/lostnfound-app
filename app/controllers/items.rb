# frozen_string_literal: true

require 'roda'

module LostNFound
  # Web controller for LostnFound API
  class App < Roda
    route('items') do |routing|
      routing.on do
        # GET /projects/
        routing.get do
          if @current_account.logged_in?
            item_list = GetAllItems.new(App.config).call(@current_account)

            items = Items.new(item_list)

            view :items_all,
                 locals: { current_user: @current_account, items: }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
