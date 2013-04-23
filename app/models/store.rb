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
    response = RestClient.get(url)
    raise "Erro na chamada de #{url}.\nResponse code #{response.code}" unless response.code == 200
    JSON.parse(response)
  end

  def order_timestamp(order, status)
    DateTime.strptime(order[status.at], '%Y-%m-%dT%H:%M:%S%:z').to_i if order[status.at]
  end

  def km_event(order, status)
    params = {
      '_k' => km_api_key,
      '_p' => order['email'],
      '_n' => status.km_event,
      '_t' => order_timestamp(order, status),
      '_d' => '1',
      'OrderID' => order['id'],
      'Order Code' => order['code'],
      'Items Quantity' => order['items'].size,
      'Name' => "#{order['first_name']} #{order['last_name']}",
      'ClientId' => order['client_id'],
      'Payment Method' => order['payment_method'],
      'Shipping Price' => order['shipping_price'],
      'Subtotal' => order['subtotal'],
      'Discount Price' => order['discount_price'],
      'Total' => order['total'],
      'Items' => km_items(order['items']),
    }.to_query
    url = "http://trk.kissmetrics.com/e?#{params}"
    RestClient.get(url)
    puts "Order #{order['id']} #{status.param} at #{order[status.at]}."
  end

  def km_items(items)
    items_hash = {}
    items.each_index do |i|
      item = items[i]
      items_hash[i+1] = {
        'SKU' => item['sku'],
        'Reference' => item['reference'],
        'Quantity' => item['quantity'],
        'Price' => item['subtotal'],
        'Total Price' => item['total']
      }
    end
    items_hash
  end

end