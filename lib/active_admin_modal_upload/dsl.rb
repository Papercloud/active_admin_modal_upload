module ActiveAdminModalUpload
  module DSL

    def modal_uploads(options={})
      config.resource_class.send(:include, ::ActiveAdminModalUpload::Uploadable)
      uploader = options[:mounted_uploader] ||= :image
      config.resource_class.send(:allows_upload,  uploader)

      collection_action :create_upload, method: :post do
        @upload_model = options[:model] ||= active_admin_config.resource_class
        @model = @upload_model.new(upload_resource_params)
        if @model.save
          respond_to do |format|
            format.html {
              render :json => [@model.to_jq_upload].to_json,
              :content_type => 'text/html',
              :layout => false
            }
            format.json {
              render :json => { files: [@model.to_jq_upload] }, status: :created
            }
          end
        else
          render :json => [{:error => "custom_failure"}], :status => 304
        end
      end

      member_action :destroy_upload, method: :delete do
        @upload_model = options[:model] ||= active_admin_config.resource_class
        @model = @upload_model.find(params[:id])
        @model.destroy
        render :json => true
      end
    end
  end
end
