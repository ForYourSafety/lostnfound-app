# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/
        routing.get String do |username|
          if @current_account && @current_account.username == username
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.new.call(routing.params)

          if passwords.failure?
            flash[:error] = Form.message_values(passwords)
            routing.redirect "#{App.config.APP_URL}/auth/register/#{registration_token}"
          end

          new_account = VerifyRegistrationToken.new(App.config).call(registration_token)
          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: routing.params['password']
          )

          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          App.logger.warn "Invalid account creation attempt: #{e.inspect}\n#{e.backtrace.join("\n")}"
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          App.logger.warn "Unexpected error during account creation: #{e.inspect}\n#{e.backtrace.join("\n")}"
          flash[:error] = 'An unexpected error occurred while creating your account. Please try again.'
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
