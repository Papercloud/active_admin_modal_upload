class ModalUploadInput

  include Formtastic::Inputs::Base
  include Jquery::Helpers
  include S3DirectUpload::UploadHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Context


  def js_to_append_modal
   "<script type='text/javascript'>
      $(document).ready(function() {
        $('#main_content').append('" + modal_window + "');
      });
    </script>
    "
  end

  def uploader_button
    link_to_modal 'Add File', "\##{options[:resource].class.name.downcase}-#{options[:association]}-uploader-window", :class => 'button', id: "#{options[:association].underscore}_uploader"
  end

  def modal_window
    resource = options[:resource].class.name.downcase
    association = options[:association]
    modal_window_id = "#{resource}-#{association}-uploader-window"
    '<div id="' + modal_window_id + '" class="modal-window-visible" style="display: none;">' +
    upload_form +
    '</div>'
  end

  def upload_form
    s3_uploader_form id: "#{options[:resource].class.name.downcase}-#{options[:association].underscore}-uploader" do
      file_field_tag :file, multiple: true
    end
  end

  def file_previews
    options[:resource].send(options[:association].to_sym).order("image ASC").each_with_index.map { |file, index|
      input_name = "#{options[:resource].class.name.downcase}[#{options[:association].underscore}_attributes][#{index}]"

      image_preview = file.image.present? ? image_tag(file.image_url(options[:preview_image_size] ||= :thumb)) : image_tag(file.temporary_image_url, width: "150px", :style => "opacity:0.3; filter:alpha(opacity=30);") + "<br/><em>*This image is still being processed</em>".html_safe

      "<div class='existing-upload'>" +
      "<div class='file-preview'>" +
        image_preview +
      "</div>" +
      "<div class='remove-file'>" +
        check_box_tag("#{input_name}[_destroy]") +
        "<p>Remove File</p>" +
        hidden_field_tag("#{input_name}[id]", file.id) +
      "</div>" +
      "</div>"
    }
  end

  def upload_template
    "<script id='template-upload' type='text/x-tmpl'>" +
      "<div id='file-{%=o.unique_id%}'' class='upload'>" +
        "{%=o.name%}" +
        "<div class='progress progress-striped active' role='progressbar'><div class='bar' class='progress-bar bar progress-bar-success' style='width: 0%;'></div></div>" +
      "</div>" +
    "</script>"
  end

  def upload_js
    "
    <script type='text/javascript'>
      $(function() {
        $('\##{options[:resource].class.name.downcase}-#{options[:association].underscore}-uploader').S3Uploader({
        }).on('s3_upload_complete', function(e, content) {


          var preview = $('<div class=\"existing-upload\"><div class=\"file-preview\"><img src=\"' + content['url'] + '\" style=\"width: 150px; opacity:0.3; filter:alpha(opacity=30);\"><br/><em>*This image is still being processed</em></div><div class=\"remove-file\"></div></div>');
          var lastPreview = $('.existing-upload').last();
          insertRemoteInput(content);
          preview.insertAfter(lastPreview);
        }).bind('s3_uploads_complete', function(e, data) {
          var processingMessage = $('<h3 style=\"text-align: center; margin-top=20px;\">Uploads completed.</h3>')
          processingMessage.insertAfter($('#file'));
        }).on('ajax:success', function(e, data) {
          insertUploadInputsForPhotographs(JSON.parse(data));
        }).on('ajax:error', function(e, data) {
          alert('Something went wrong');
        }).bind('s3_upload_failed', function(e, content) {
          return alert('' + content.filename + ' failed to upload : ' + content.error_thrown);
        });
      });

      var insertRemoteInput = function(content) {
        input = $('<input type=\"hidden\" name=\"#{options[:resource].class.name.downcase}[#{options[:association].underscore}_attributes][' + $.now() + '][temporary_image_url]\" value=\"' + content.url + '\" />');
        input.insertAfter($('\##{options[:association].underscore}_uploader'));
      }
    </script>
    "
  end

  def placeholder
    "<div class='existing-upload'></div>"
  end


  def to_html
    input_wrapping do
      label_html <<
      uploader_button <<
      file_previews.join(" ").html_safe <<
      placeholder.html_safe <<
      upload_template.html_safe <<
      js_to_append_modal.html_safe <<
      upload_js.html_safe
    end
  end

end
