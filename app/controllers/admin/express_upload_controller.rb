class Admin::ExpressUploadController < Admin::ApplicationController
  include ExpressHelper
  def new
    path="/tmp/1001.xlsx"
    path=File.join(Rails.root,path)
    if File.exist?(path)
      # @results= Express_import.import(path)
      workbook = RubyXL::Parser.parse(path)
      worksheet = workbook[0]
      @results=Array.new
      $i=1
      while true do
        logger.debug $i
        if !worksheet.sheet_data[$i]||worksheet.sheet_data[$i][0].value.length<1
            break
        end
        express=Array.new
        express<<worksheet.sheet_data[$i][2].value
        express<<worksheet.sheet_data[$i][11].value
        express<<worksheet.sheet_data[$i][12].value
        if express[0].to_s.length>0
          @results<<express
        end
        $i +=1;
      end

      # @results<<worksheet.sheet_data[0][0].value
      # @results<<worksheet.sheet_data[1][0].value
    end
  end

  def create

    post = save(params[:upload],"1001.xlsx")
    render :text => "File has been uploaded successfully"
  end
  private
  def save(upload,filename)
    # name =  upload['datafile'].original_filename
    name=filename
    directory = "/tmp"
    directory=File.path(directory)
    # create the file path
    path = File.join(directory, name)
    path=File.join(Rails.root,path)
    if  !File.exist?(path)
     logger.debug "1111"+path
    end
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end
end
