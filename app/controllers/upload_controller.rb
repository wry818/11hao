class UploadController < ApplicationController
  def campaign_photo
    upload = params[:photo_upload]
    image_hash = Cloudinary::Uploader.upload(upload, :tags => "custom-campaign-image")
       
    render text: {public_id: image_hash["public_id"], url: image_hash["secure_url"]}.to_json + "upload.done"
  end
  
  def product_photo
    upload = params[:photo_upload]
    image_hash = Cloudinary::Uploader.upload(upload, :tags => "custom-product-image")
       
    render text: {public_id: image_hash["public_id"], url: image_hash["secure_url"]}.to_json + "upload.done"
  end
end
