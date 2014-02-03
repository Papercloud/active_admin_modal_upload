module ActiveAdminModalUpload::Uploadable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  module ClassMethods
    def allows_upload(name)
      code = <<-eoruby

        after_save :delay_processing, :if => :temporary_image_url_changed?

        def to_jq_upload
          {
            "name" => read_attribute(#{name}),
            "size" => image.size,
            "url" => image.url,
            "thumbnail_url" => image.thumb.url,
            "delete_url" => destroy_upload_admin_#{self.name.underscore}_url(self, only_path: true),
            "id" => id,
            "delete_type" => "DELETE"
          }
        end

        def delay_processing
          #{self.name}.delay.save_remote_file(self.id)
        end

        def self.save_remote_file(id)
          file = #{self.name}.where(id: id).first
          if file
            file.remote_image_url = file.temporary_image_url
            file.save!
          end
        end
      eoruby
      class_eval(code)
    end
  end
end
