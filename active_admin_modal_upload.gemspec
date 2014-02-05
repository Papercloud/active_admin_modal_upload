$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_admin_modal_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_admin_modal_upload"
  s.version     = ActiveAdminModalUpload::VERSION
  s.authors     = ["Isaac Norman"]
  s.email       = ["isaacdnorman@gmail.com"]
  s.homepage    = "http://www.papercloud.com.au"
  s.summary     = "Modal uploads in ActiveAdmin"
  s.description = "Allows for the upload of multiple files in the background from a modal window in Active Admin"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "s3_direct_upload"
  s.add_dependency "jquery-ui-rails"
  s.add_dependency "jquery-modal-rails"
  s.add_dependency "sidekiq"

  s.add_development_dependency "sqlite3"
end
