require 'redmine'
require 'redmine_cas2'

# Patches to existing classes/modules
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_cas2/account_helper_patch'
  require_dependency 'redmine_cas2/account_controller_patch'
  require_dependency 'redmine_cas2/user_patch'
end

# Plugin generic informations
Redmine::Plugin.register :redmine_cas2 do
  name 'Redmine CAS2 plugin'
  description 'This is a plugin for Redmine that allows CAS authentication.  It is based on previous plugins but rewritten from scratch specifically for Redmine 2.x'
  author 'Moshe Katz'
  author_url 'http://ymkatz.net'
  url 'http://github.com/kohenkatz/redmine_cas2'
  version '0.0.1'
  requires_redmine :version_or_higher => '2.0.0'
#  settings :default => { 'label_login_with_cas' => '', 'cas_server' => '' },
#           :partial => 'settings/cas2_settings'

  menu  :account_menu,
          :login_with_cas,
          {
            :controller => 'account',
            :action     => 'login_with_cas'
          },
          :caption => :label_login_with_cas,
          :after   => :login,
          :if      => Proc.new { Redmine::CAS2.enabled? && !User.current.logged? }
  
    settings :default => {
      :cas_enabled                     => false,
      :cas_server                      => '',
      :auto_create_users               => false,
    },
    :partial => 'settings/cas2_settings'

end

# Set Up CAS
require 'casclient'
require 'casclient/frameworks/rails/filter'

addr = Redmine::CAS2.cas_server
cas_server = URI.parse(addr)
if cas_server # if the URL is valid
  CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => addr,
#    :enable_single_sign_out => true
  )
end
#  validate = Redmine::OmniAuthCAS.cas_service_validate_url
#  if validate
#    env['omniauth.strategy'].options.merge! :service_validate_url => validate
#  end
