Active Admin Modal Upload
=========================

This gem allows you tp upload nested attributes directly to S3, and then process them with Carrierwave in the background.

### Nifty Features:

* Background worker processing using sidekiq
* Uploads direct to S3 so you don't hit any Heroku (or other) timeouts
* Progress bars!
* File previews before carrierwave is done processing
* It can handle more than one uploader in a form
* Many other cool things.

This gem is largely based off the excellent [S3DirectUpload](https://github.com/waynehoover/s3_direct_upload) gem by Wayne Hoover, and relies on a working [Carrierwave](https://github.com/carrierwaveuploader/carrierwave) uploader to work. If you are not familiar with Carrierwave, I'd advise you to check out [This Railscast](http://railscasts.com/episodes/253-carrierwave-file-uploads) and familiarise yourself first. It would also help to be familiar with the [Cocoon](https://github.com/nathanvda/cocoon) gem, as it takes a lot of queues from nesting attributes from there.

Before you start
==================

There are currently just a few limitations on this gem:

1. The column name that has the uploader associated with it must be called `:image`
2. It currently requires an extra column on the associated model.
3. This additional column must be named `temporary_image_url`

But it's totally worth it. I promise.

Getting Started
===============


Carrierwave
--------------

This gem relies on [Carrierwave](https://github.com/carrierwaveuploader/carrierwave) to work. If you are unfamiliar with Carrierwave then I recommend have a look through it before using this gem. You can also check out [This Railscast](http://railscasts.com/episodes/253-carrierwave-file-uploads) by Ryan Bates to help you get started.


Install the gem
-----------------

In your Gemfile:

`gem 'active_admin_modal_upload'`

`bundle install`


Run the generator
----------------

`rails g active_admin_modal_upload:initialize`

This will add the necessary JS and CSS to your ActiveAdmin files.


Setup your uploads
===========

For the sake of simplification for all examples below I am going to use the sample data.

* `Picture` will be the model that has an uploader associated with its `:image` attribute
* `Gallery` has many `:pictures`

You can also assume the `@gallery` refers to the current gallery that we are creating/editing.

**Substiture your own models and associations as necessary**

### Add the temporary_image_column

This extra column is required so that Carrierwave knows where to grab the image from on S3 for processing. It's also used to display a temporary preview of the image before it is processed

`rails g migration add_temporary_image_url_to_picture temporary_image_url:string`

`rake db:migrate`


### Initialize S3 Direct Uploads

in `config/initializers/s3_direct_upload.rb` add the following code:

`````````````
S3DirectUpload.config do |c|
  c.access_key_id = ENV['AWS_ACCESS_KEY_ID']           # your access key id
  c.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]   # your secret access key
  c.bucket = ENV['FOG_DIRECTORY']                      # your bucket name
  c.region = nil                                       # region prefix of your bucket url (optional), eg. "s3-eu-west-1"
  c.url = nil                                          # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"
end
``````````````

Make sure your AWS S3 CORS settings for your bucket look something like this:

``````````````````````
<CORSConfiguration>
    <CORSRule>
        <AllowedOrigin>http://0.0.0.0:3000</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
``````````````````````````

In production the AllowedOrigin key should be your domain.


### Allow the params

In `app/admin/gallery.rb` allow the following:

`permit_params :gallery_pictures_attributes => [:id, :_destroy, :gallery_id, :temporary_image_url]`

**Note:** For some reason ActiveAdmin throws an error if you try and pass it a has similar to the above, unless it is *after* all the other params. So I would recommend putting this set of params last.

Now, in your model (`app/models/gallery.rb`) add the following:

`accepts_nested_attributes_for :pictures, :allow_destroy => true`

This allows you to delete the pictures from within your gallery form, instead of having to seek them out individually.

### Add the 'Magic Words'

In `app/admin/picture.rb` *(note that we are now on the picture object)* add the following:

`modal_uploads`

### And you are all setup!

Now lets get down to how to use this new magical uploader.


Usage
===============

Using the gem is as simple as using the new input type included with the gem!

In your form partial for `Gallery` simply use the following:

``````````````````
<%= f.inputs "Pictures" do %>
  <%= f.input :pictures, :as => :modal_upload, :resource => @gallery, :association => "pictures", :attribute => "image", :preview_image_size => :thumb %>
<% end %>
``````````````````

And that's it! This will add a button, that when clicked will invoke the modal uploader, and away you go from there.

### How it works

Below are a list of all the options and how they are used.

* `:resource` is the parent model, taken as a variable. `@gallery` in this case.
* `:association` is the associated (or nested) model, taken as a string. `"pictures"` in this case.
* `:attribute` is the name of attribute of the nested model where the uploader is mounted, taken as a string At this stage it must be `"image"`.
* `:preview_image_size` is used by carrierwave to determine what size to show previews of the images in the form. Defaults to `:thumb`, but can be overridden if you are using RMagick to resize your images.

Contributing
==============

If you see something that you think you could do better, then don't be afraid to show it! Fork a branch and then submit a pull request.

Just make sure that your branch is well tested, and that you have documented what your changes do.

Upcoming Features
================

This gem is not yet at a 1.0 release. I am still actively developing it to include a few more things such as:

- Prettier Modal Window
- Better progress bars
- Upload cancellation
- Slicker UI.

If there is anything else you would like to see then let me know, or fork a branch and show me your stuff!

Thanks
=========

This gem is largely based off the s3_direct_upload gem mentioned above, and wouldn't be possible without it.


This project rocks and uses MIT-LICENSE.
