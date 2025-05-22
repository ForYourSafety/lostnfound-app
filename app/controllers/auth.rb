# frozen_string_literal: true

require 'roda'
require_relative './app'

module LostNFound
  # Web controller for LostNFound API
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )

          SecureSession.new(session).set(:current_account, account)
          flash[:notice] = "Welcome back #{account['username']}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 400
          view :login
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @logout_route = '/auth/logout'
      routing.on 'logout' do
        # GET /auth/logout
        routing.get do
          SecureSession.new(session).delete(:current_account)
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do # rubocop:disable Metrics/BlockLength
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            account_data = routing.params.transform_keys(&:to_sym)

            VerifyRegistration.new(App.config).call(account_data)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            routing.redirect @register_route
          rescue VerifyRegistration::VerificationError => e
            App.logger.warn "Email token verification error: #{e.inspect}"
            flash[:error] = "Invalid registration: #{e.message}"
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.error "Could not process registration: #{e.inspect}\n#{e.backtrace.join("\n")}"
            flash[:error] = 'Registration process failed -- please try later'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          new_account = SecureMessage.new(registration_token).decrypt
          exp = new_account.delete('exp')

          if Time.now.to_i > exp
            # Token has expired
            raise(VerifyRegistration::VerificationError,
                  'Registration token has expired. Please submit a new request again.')
          end

          flash.now[:notice] = 'Email Verified! Please choose a new password'

          view :register_confirm,
               locals: { new_account:,
                         registration_token: }
        rescue VerifyRegistration::VerificationError => e
          App.logger.warn "Email token verification error: #{e.inspect}"
          flash[:error] = e.message
          routing.redirect @register_route
        rescue StandardError => e
          App.logger.error "Could not process registration: #{e.inspect}"
          flash[:error] = 'Registration process failed -- please try later'
          routing.redirect @register_route
        end
      end
    end
  end
end
