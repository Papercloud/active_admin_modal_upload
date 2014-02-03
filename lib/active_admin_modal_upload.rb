require "active_admin_modal_upload/engine"
require "active_admin_modal_upload/dsl"

module ActiveAdminModalUpload
end

::ActiveAdmin::DSL.send(:include, ActiveAdminModalUpload::DSL)
