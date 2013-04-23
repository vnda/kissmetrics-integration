class Object
  def to_query(key)
    require 'erb' unless defined?(ERB::Util) && defined?(ERB::Util.url_encode)
    "#{ERB::Util.url_encode(key.to_param)}=#{ERB::Util.url_encode(to_param.to_s)}"
  end
end