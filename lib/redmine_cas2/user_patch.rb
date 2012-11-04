require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'

module Redmine::CAS2
  module UserPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable # Mark as unloadable so it is reloaded in development
        alias_method_chain :change_password_allowed?, :cas
      end
    end
  
    module InstanceMethods
      def change_password_allowed_with_cas?
        (Redmine::CAS2.enabled? && auth_source_id == "CAS") ? false : change_password_allowed_without_cas?
      end
    end
  end
end

User.send(:include, Redmine::CAS2::UserPatch)