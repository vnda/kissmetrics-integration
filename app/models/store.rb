class Store < ActiveRecord::Base

  def orders_api_url(status, min_updated_at = nil)
    url = "http://#{user}:#{pass}@#{domain}/api/orders?status=#{status.param}"
    url << "&min_updated_at=#{min_updated_at}" if min_updated_at.present?
    url
  end

  def last_order_date(status)
    send(status.last_order_date_column)
  end

  def set_last_order_date(status, order_date)
    send("#{status.last_order_date_column}=", order_date)
    save!
  end

  def get_orders(status, min_updated_at)
    url = orders_api_url(status, min_updated_at)
    response = RestClient.get_with_retry(url)
    raise "Erro na chamada de #{url}.\nResponse code #{response.code}" unless response.code == 200
    JSON.parse(response).map { |order_hash| Order.new(self, status, order_hash) }
  end

end