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

            if item_data.nil?
              response.status = 400
              return { message: 'Item could not be created.' }.to_json
            end

            flash[:success] = 'Item created successfully.'
            response.status = 201
            response['Location'] = "/items/#{item_data['attributes']['id']}"
            { message: 'Item saved', data: item_data }.to_json
          end
        end

        routing.on String do |item_id|
          routing.on 'delete' do
            # POST /items/:item_id/delete
            routing.post do
              unless @current_account.logged_in?
                flash[:error] = 'You must be logged in to delete an item.'
                routing.redirect '/auth/login'
              end

              result = DeleteItem.new(App.config).call(
                current_account: @current_account,
                item_id: item_id
              )

              unless result
                response.status = 404
                flash[:error] = 'Item could not be deleted.'
                routing.redirect "/items/#{item_id}"
              end

              flash[:notice] = 'Item deleted successfully.'
              routing.redirect '/items'
            end
          end

          # GET /items/:item_id
          routing.get do
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
