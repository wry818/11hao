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
  def photo
    upload = params[:photo_upload]
    if ((upload.size)>(1024*1024*1))
      logger.debug "1001:"+upload.size.to_s
      render :text => "max" and return
    end
    save(upload);
    img = MiniMagick::Image.open @filepath

    if img.width>800
      img.resize "800x#{(800*img.height)/img.width}"
      img.write @filepath
    end
    render text: {fullname:@fullname}.to_json+ "upload.done"
  end
  def photo_croper
    if params[:filename]
      filepath="#{Rails.root}/public#{params[:filename]}";
      img = MiniMagick::Image.open filepath
      if params[:x]&&params[:x].to_i&&params[:y]&&params[:y].to_i&&params[:height]&&params[:height].to_i&&params[:width]&&params[:width].to_i
        img.crop "#{params[:width]}x#{params[:height]}+#{params[:x]}+#{params[:y]}"
        img.write filepath
      end

    end

    render text: "isok"
  end
  private
  def save(upload)
    name= UUIDTools::UUID.timestamp_create.to_s.gsub('-', '')
    # name =  upload['datafile'].original_filename
    directory = "#{Rails.root}/public/uploadsimg/"
    logger.debug Rails.root
    logger.debug directory
    if !File.exist?(directory)
      FileUtils.mkdir_p(directory)
    end
    # directory=File.path(directory)
    # create the file path
    path=File.join(directory,"#{name}.jpg")
    @fullname= "/uploadsimg/#{name}.jpg"

    @filepath=path
    # write the file
    File.open(path, "wb") { |f| f.write(upload.read) }
  end
end
