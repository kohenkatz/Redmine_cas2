require_dependency 'account_controller'
require 'casclient'
require 'casclient/frameworks/rails/filter'

module Redmine::CAS2
  module AccountControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable # Mark as unloadable so it is reloaded in development
        alias_method_chain :register, :cas
      end
    end

    module InstanceMethods
      def login_with_cas
        if Redmine::CAS2.enabled?
          if ( session[:cas_user].nil? || session[:cas_user].empty?)
            # Logged out user
            self.logged_user = nil
            if CASClient::Frameworks::Rails::Filter.filter(self)
              cas_auth(session[:cas_user])
            end
          else
            cas_auth(session[:cas_user])
          end
        else
          login
        end
      end
      
      def logout_with_cas
        if Redmine::CAS2.enabled?
          self.logged_user = nil
          CASClient::Frameworks::Rails::Filter::logout(self, home_url)
        else
          logout
        end
      end
      
      def register_with_cas
        set_language_if_valid params[:user][:language] rescue nil # Show the activation message in the user's language
        register_without_cas
        if Redmine::CAS2.enabled? and !performed?
          render :template => 'account/register_with_cas'
        end
      end
  
      private
        def cas_auth(cas_user)
          user = User.find_by_login(cas_user)
          if user
            if user.active?
              successful_authentication(user)
            else
              account_pending
            end
          else
            if Redmine::CAS2.cas_onthefly_register
              # Plugin config says to create user
              user = User.new
              #user.attributes = RedmineCas.user_attributes_by_session(session)
              #user.status = User::STATUS_REGISTERED
              #
              #register_automatically(user) do
              #  onthefly_creation_failed(user)
              #end
              
              user.login = session[:cas_user]
              @user = user
              session[:auth_source_registration] = { :login => @user.login, :auth_source_id => "CAS" }
              render :template => 'account/register_with_cas'
            else
              # User auto-create disabled in plugin config
              invalid_credentials
              error = l(:notice_account_invalid_creditentials)
              if cas_url.present?
                link = self.class.helpers.link_to(l(:text_logout_from_cas), cas_url+"/logout", :target => "_blank")
                error << ". #{l(:text_full_logout_proposal, :value => link)}"
              end
              flash[:error] = error
              redirect_to signin_url
            end
          end
        end
        
        def cas_url
          Redmine::CAS2.cas_server
        end
    end
  end
end

AccountController.send(:include, Redmine::CAS2::AccountControllerPatch)