class WeixinCache
  
  @@weixin_cache = {}
  
  # def self.set(value)
  #   @@weixin_cache = value
  # end
  #
  # def self.get()
  #   @@weixin_cache
  # end
  
  def self.set(openid_name, value)
    openid_name = openid_name.to_s
    @@weixin_cache[openid_name] = value
  end

  def self.get(openid_name)
    openid_name = openid_name.to_s
    @@weixin_cache[openid_name]
  end

  def self.[]=(openid_name, value)
    openid_name = openid_name.to_s
    self.set(openid_name, value)
  end

  def self.[](openid_name)
    openid_name = openid_name.to_s
    self.get(openid_name)
  end

  def self.has_key?(key)
    key = key.to_s
    @@weixin_cache.has_key?(key)
  end

  def self.key?(key)
    self.has_key?(key)
  end
  
  def self.clear()
    @@weixin_cache.clear
  end
  
end