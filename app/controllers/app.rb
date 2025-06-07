# frozen_string_literal: true

require 'roda'
require 'slim'

module LostNFound
  # Base class for LostNFound Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets', group_subdirs: false,
                    css: {
                      style: 'style.css',
                      multiselect: 'MultiSelect.css'
                    },
                    js: {
                      item_all: 'item_all.js',
                      multiselect: 'MultiSelect.js'
                    }
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route
    plugin :flash

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = CurrentSession.new(session).current_account

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
