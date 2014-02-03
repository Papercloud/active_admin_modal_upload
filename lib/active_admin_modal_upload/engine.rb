module ActiveAdminModalUpload
  class Engine < ::Rails::Engine
    require "s3_direct_upload"
    require "jquery-ui-rails"
    require "jquery-modal-rails"
  end
end
