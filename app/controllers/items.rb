# frozen_string_literal: true

require 'roda'

module LostNFound
  # Web controller for LostnFound API
  class App < Roda
    route('items') do |routing|
      routing.on do
        routing.on 'new' do
          # GET /items/new
          routing.get do
            unless @current_account.logged_in?
              flash[:error] = 'You must be logged in to create a new item.'
              routing.redirect '/auth/login'
            end

            all_tags_data = GetAllTags.new(App.config).call(@current_account)
            all_tags = Tags.new(all_tags_data)

            view :item_new,
                 locals: { current_user: @current_account, all_tags: }
          end

          # POST /items/new
          routing.post do
            unless @current_account.logged_in?
              response.status = 401
              return { message: 'You must be logged in to create a new item.' }.to_json
            end

            item_form = Form::NewItem.new.call(routing.params)
            if item_form.failure?
              response.status = 400
              return { message: Form.message_values(item_form) }.to_json
            end

            item_data = CreateItem.new(App.config).call(
              current_account: @current_account,
              item_params: item_form.to_h
            )

            flash[:success] = 'Item created successfully.'
            response.status = 201
            response['Location'] = "/items/#{item_data['attributes']['id']}"
            { message: 'Item saved', data: item_data }.to_json
          end
        end

        # GET /items/:item_id
        routing.get String do |item_id|
          item_json = GetItem.new(App.config).call(
            current_account: @current_account,
            item_id: item_id
          )

          if item_json.nil?
            flash[:error] = "Item with ID #{item_id} not found."
            routing.redirect '/items'
          end

          item = Item.new(item_json)

          view :item,
               locals: { current_user: @current_account, item: item }
        end

        # GET /items/
        routing.get do
          item_data = GetAllItems.new(App.config).call(@current_account)
          items = Items.new(item_data)

          all_tags_data = GetAllTags.new(App.config).call(@current_account)
          all_tags = Tags.new(all_tags_data)

          view :item_all,
               locals: { current_user: @current_account, items:, all_tags: }
        end
      end
    end
  end
end
