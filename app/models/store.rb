class Store < ActiveRecord::Base

  def orders_api_url(status, since_id)
    "http://#{user}:#{pass}@#{domain}/api/orders?status=#{status.param}&since_id=#{since_id}"
  end

  def last_order_id(status)
    send(status.last_order_id_column)
  end

  def set_last_order_id(status, order_id)
    send("#{status.last_order_id_column}=", order_id)
    save!
  end

  def get_orders(status, since_order_id)
    url = orders_api_url(status, since_order_id)
    response = RestClient.get_with_retry(url)
    raise "Erro na chamada de #{url}.\nResponse code #{response.code}" unless response.code == 200
    JSON.parse(response).map { |order_hash| Order.new(self, status, order_hash) }
  end

end