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

          routing.on 'resolve' do
            # POST /items/:item_id/resolve
            routing.post do
              unless @current_account.logged_in?
                flash[:error] = 'You must be logged in to resolve an item.'
                routing.redirect '/auth/login'
              end

              result = ResolveItem.new(App.config).call(
                current_account: @current_account,
                item_id: item_id
              )

              unless result
                response.status = 400
                flash[:error] = 'Item could not be resolved.'
                routing.redirect "/items/#{item_id}"
              end

              flash[:notice] = 'Item resolved.'
              routing.redirect "/items/#{item_id}"
            end
          end

          routing.on 'edit' do
            # GET /items/:item_id/edit
            routing.get do
              unless @current_account.logged_in?
                flash[:error] = 'You must be logged in to edit an item.'
                routing.redirect '/auth/login'
              end

              item_data = GetItem.new(App.config).call(
                current_account: @current_account,
                item_id: item_id
              )

              if item_data.nil?
                flash[:error] = "Item with ID #{item_id} not found."
                routing.redirect '/items'
              end

              item = Item.new(item_data)

              all_tags_data = GetAllTags.new(App.config).call(@current_account)
              all_tags = Tags.new(all_tags_data)

              view :item_edit,
                   locals: { current_user: @current_account, item: item, all_tags: all_tags }
            end

            # POST /items/:item_id/edit
            routing.post do
              unless @current_account.logged_in?
                response.status = 401
                return { message: 'You must be logged in to edit an item.' }.to_json
              end

              item_form = Form::EditItem.new.call(routing.params)
              if item_form.failure?
                response.status = 400
                return { message: Form.message_values(item_form) }.to_json
              end

              item_data = UpdateItem.new(App.config).call(
                current_account: @current_account,
                item_id: item_id,
                item_params: item_form.to_h
              )

              if item_data.nil?
                response.status = 400
                return { message: 'Item could not be updated.' }.to_json
              end

              flash[:success] = 'Item updated successfully.'
              response.status = 200
              { message: 'Item updated', data: item_data }.to_json
            end
          end

          routing.on 'requests' do
            unless @current_account.logged_in?
              flash[:error] = 'You must be logged in to access the requests of an item.'
              routing.redirect '/auth/login'
            end

            # GET /items/:item_id/requests
            routing.get do
              requests_data = GetItemRequests.new(App.config).call(
                current_account: @current_account,
                item_id: item_id
              )

              if requests_data.nil?
                flash[:error] = 'Could not get requests for item'
                routing.redirect "/items/#{item_id}"
              end

              requests = Requests.new(requests_data)

              if requests.all.empty?
                flash[:notice] = 'There are no requests to this item yet.'
                routing.redirect "/items/#{item_id}"
              end

              for_item = requests.all[0].item

              view :request_list,
                   locals: { current_user: @current_account, requests:, for_item:, to_me: false }
            end

            # POST /items/:item_id/requests
            routing.post do
              request_form = Form::NewRequest.new.call(routing.params)
              if request_form.failure?
                response.status = 400
                flash[:error] = Form.message_values(request_form)
                routing.redirect "/items/#{item_id}"
              end

              result = CreateRequest.new(App.config).call(
                current_account: @current_account,
                item_id: item_id,
                request_params: request_form.to_h
              )

              unless result
                response.status = 400
                flash[:error] = 'Request could not be sent.'
                routing.redirect "/items/#{item_id}"
              end

              flash[:notice] = 'Request sent successfully.'
              routing.redirect "/items/#{item_id}/requests"
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

          view :item_list,
               locals: { current_user: @current_account, items:, all_tags:, mine: false }
        end
      end
    end
  end
end
