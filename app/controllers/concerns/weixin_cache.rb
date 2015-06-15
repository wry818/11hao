class WeixinCache
  
  @@weixin_cache = ""
  
  def self.set(value)
    @@weixin_cache = value
  end
  
  def self.get()
    @@weixin_cache
  end
  
end