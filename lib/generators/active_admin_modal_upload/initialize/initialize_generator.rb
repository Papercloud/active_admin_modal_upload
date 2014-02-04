module ActiveAdminModalUpload
  class InitializeGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def add_js_assets
      append_file "app/assets/javascripts/active_admin.js.coffee", "#= require jquery.ui.all\n"
      append_file "app/assets/javascripts/active_admin.js.coffee", "#= require jquery.modal\n"
      append_file "app/assets/javascripts/active_admin.js.coffee", "#= require s3_direct_upload\n"
    end

    def add_css_assets
      append_file "app/assets/stylesheets/active_admin.css.scss", "@import 'jquery.ui.all';\n"
      append_file "app/assets/stylesheets/active_admin.css.scss", "@import 'jquery.modal';\n"
      append_file "app/assets/stylesheets/active_admin.css.scss", "@import 's3_direct_upload_progress_bars';\n"
    end
  end
end
