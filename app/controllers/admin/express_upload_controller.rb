class Admin::ExpressUploadController < Admin::ApplicationController
  include ExpressHelper

  def new


  end

  def load_excle
    begin
      @results=load_data_from_excel()
    rescue
      delete()
      render text: "error" and return
    end
    # session[:express_results]=@results
    render partial: "table_show"
  end

  def validate_check
    msg="ok"
    begin
      results=load_data_from_excel()

      results.each do |result|
        logger.debug result[0]
        item_id=result[0].to_s
        logger.debug "1003"+item_id
        item=Item.where(:id => item_id).first
        if item
        else
          msg="订单详情号为:"+item_id+" 的数据在数据库中不存在"
          delete()
          break
        end
      end
    rescue
      msg="error"
      delete()
    end
    render text: msg
  end

  def update_data
    msg="ok"
    begin
      results=load_data_from_excel()
      Item.transaction do
        results.each do |result|
          logger.debug result[0]
          item_id=result[0].to_s
          logger.debug "1003"+item_id
          item=Item.where(:id => item_id).first
          if item
            item.update(:express => result[1])
            item.update(:courier_number => result[2])
          end
        end
      end
    rescue
      msg="error"
    end
    delete()
    render text: msg
  end

  def create

    name= UUIDTools::UUID.timestamp_create.to_s.gsub('-', '')
    fullname= "/tmp/#{name}.xlsx"

    if ((params[:upload]['datafile'].size)>(1024*1024*1))
      logger.debug "1001:"+params[:upload]['datafile'].size.to_s
      render :text => "max" and return
    end
    begin
      post = save(params[:upload], fullname)
      session[:express_import]=fullname
    rescue
      render :text => "error" and return
    end


    render :text => "ok"
  end

  private
  def load_data_from_excel
    logger.debug "1001"
    results=nil
    if session[:express_import]
      logger.debug "1002"
      # logger.debug session[:express_import]

      path=session[:express_import]
      path=File.join(Rails.root, path)
      logger.debug path
      if File.exist?(path)
        # @results= Express_import.import(path)
        workbook = RubyXL::Parser.parse(path)
        worksheet = workbook[0]

        express_indexs=Array.new
        $int=0
        while true do

          if !worksheet.sheet_data[0]||!worksheet.sheet_data[0][$int]||worksheet.sheet_data[0][$int].value.length<1
            break
          end
          # logger.debug worksheet.sheet_data[0][$int].value
          if worksheet.sheet_data[0][$int].value.to_s=="订单详情号"
            express_indexs[0]=$int;
          elsif worksheet.sheet_data[0][$int].value=="物流公司"
            express_indexs[1]=$int;
          elsif worksheet.sheet_data[0][$int].value=="物流单号"
            express_indexs[2]=$int;
          end
          $int +=1;
        end

        logger.debug express_indexs.inspect

        results=Array.new
        $i=1
        while true do
          # logger.debug $i
          if !worksheet.sheet_data[$i]||worksheet.sheet_data[$i][0].value.length<1
            break
          end
          express=Array.new
          express<<worksheet.sheet_data[$i][express_indexs[0].to_i].value
          express<<worksheet.sheet_data[$i][express_indexs[1].to_i].value
          express<<worksheet.sheet_data[$i][express_indexs[2].to_i].value
          if express[0].to_s.length>0
            results<<express
          end
          $i +=1;
        end
        # @results<<worksheet.sheet_data[0][0].value
        # @results<<worksheet.sheet_data[1][0].value
      end
    end
    return results
  end

  def save(upload, filename)

    # name =  upload['datafile'].original_filename
    name=filename
    directory = ""
    # directory=File.path(directory)
    # create the file path
    path = File.join(directory, name)
    path=File.join(Rails.root, path)
    if !File.exist?(path)
      logger.debug "1111"+path
    end
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end

  def delete()
    name= session[:express_import]
    directory = ""
    # directory=File.path(directory)
    # create the file path
    path = File.join(directory, name)
    path=File.join(Rails.root, path)
    if File.exist?(path)
      File.delete(path)
      logger.debug "1111"+path
    end

  end
end
