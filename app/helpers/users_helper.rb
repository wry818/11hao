module UsersHelper

  def get_status_text(code)
    # -1	待查询、在批量查询中才会出现的状态,指提交后还没有进行任何更新的单号
    # 0	查询异常
    # 1	暂无记录、单号没有任何跟踪记录
    # 2	在途中
    # 3	派送中
    # 4	已签收
    # 5	拒收、用户拒签
    # 6	疑难件、以为某些原因无法进行派送
    # 7	无效单
    # 8	超时单
    # 9	签收失败
    dic=Hash.new
    dic['-1']="还没有进行任何更新"
    dic['1']="查询异常"
    dic['2']="在途中"
    dic['3']="派送中"
    dic['4']="已签收"
    dic['5']="拒收、用户拒签"
    dic['6']="疑难件、以为某些原因无法进行派送"
    dic['7']="无效单"
    dic['8']="超时单"
    dic['9']="签收失败"
    if dic.has_key?(code)
      return dic[code]
    else
      return "状态码不存在";
    end
  end


  def get_doc(express, number)
    # logger.debug @@result
    key=Rails.configuration.express_key
    express_id=get_express_key(express)
    url="http://www.kuaidiapi.cn/rest/?uid=53100&key=#{key}&order=#{number}&id=#{express_id}&show=xml&ord=desc"
    logger.debug "1001"
    response = open(url).read
    logger.debug response
    docresult = Nokogiri::XML(response)
    docresult.encoding = "utf-8"
    return docresult
  end
  @@result=JSON.parse(File.read("#{Rails.root}/config/express_business.json"))
  @@express_all=Hash.new
  @@result.each { |item| @@express_all[item["expressname"]]=item["expresskey"] }
  def get_express_key(express_name)
    # logger.debug @@express_all[express_name]
    return @@express_all[express_name]
  end
end
