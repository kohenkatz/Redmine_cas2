RedmineApp::Application.routes.draw do
  match 'login_with_cas', :to => 'account#login_with_cas', :as => 'signin_with_cas'
end
