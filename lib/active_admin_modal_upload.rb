require "active_admin_modal_upload/engine"
require "active_admin_modal_upload/dsl"
require "s3_direct_upload"
require "jquery-ui-rails"
require "jquery-modal-rails"
require "active_admin_modal_upload/inputs/modal_upload_input"

module ActiveAdminModalUpload
end

::ActiveAdmin::DSL.send(:include, ActiveAdminModalUpload::DSL)
