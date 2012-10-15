module Redmine::CAS2
  module AccountHelperPatch
    def label_for_cas_login
      Redmine::CAS2.label_login_with_cas.presence || l(:label_login_with_cas)
    end
  end
end
AccountHelper.send(:include, Redmine::CAS2::AccountHelperPatch)
