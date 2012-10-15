module Redmine::CAS2
  class << self
    def settings_hash
      Setting["plugin_redmine_cas2"]
    end

    def cas_enabled
      settings_hash["cas_enabled"]
    end

    def cas_server
      settings_hash["cas_server"]
    end

    def cas_service_validate_url
      settings_hash["cas_service_validate_url"].presence || nil
    end

    def label_login_with_cas
      settings_hash["label_login_with_cas"]
    end
    
    def cas_onthefly_register
      settings_hash["cas_onthefly_register"]
    end
    
    def enabled?
      cas_enabled && !cas_server.blank?
    end
  end
end
