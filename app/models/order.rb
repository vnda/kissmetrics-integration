class Order < Struct.new(
  :store,
  :id,
  :code,
  :first_name,
  :last_name,
  :email,
  :client_id,
  :slip,
  :slip_url,
  :slip_token,
  :payment_method,
  :shipping_price,
  :subtotal,
  :discount_price,
  :total,
  :items,
  :received_at,
  :confirmed_at,
  :canceled_at,
  :status,
)

  def initialize(store, status, order_hash)
    self.store = store
    self.status = status
    order_hash.each_pair do |key, value|
      self[key] = value unless key == "status"
    end
  end

  def status_timestamp
    DateTime.strptime(send(status.at), '%Y-%m-%dT%H:%M:%S%:z').to_i if send(status.at)
  end

  def km_api_main_parameters
    {
      '_k' => store.km_api_key,
      '_p' => email,
      '_t' => status_timestamp,
      '_d' => '1',
    }
  end

  # http://support.kissmetrics.com/apis/specifications.html#recording-an-event
  def km_record_event_url
    params = km_api_main_parameters.merge({
      '_n' => status.km_event,
      'OrderID' => id,
      'Order Code' => code,
      'Items Quantity' => items.size,
      'Name' => "#{first_name} #{last_name}",
      'ClientId' => client_id,
      'Payment Method' => payment_method,
      'Shipping Price' => shipping_price,
      'Subtotal' => subtotal,
      'Discount Price' => discount_price,
      status.km_total_property => total,
    })
    "http://trk.kissmetrics.com/e?#{params.to_query}"
  end

  # http://support.kissmetrics.com/apis/specifications.html#setting-properties
  def km_set_item_properites_url(index, item)
    params = km_api_main_parameters.merge({
      "#{status.km_item_prefix} Item" => {
        index => {
          'SKU' => item['sku'],
          'Reference' => item['reference'],
          'Quantity' => item['quantity'],
          'Price' => item['subtotal'],
          'Total Price' => item['total']
        }
      },
    })
    "http://trk.kissmetrics.com/s?#{params.to_query}"
  end

  def km_event
    RestClient.get_with_retry(km_record_event_url)
    puts "Order #{id} #{status.param} at #{send(status.at)}."
    items.each_index do |i|
      RestClient.get_with_retry(km_set_item_properites_url(i+1, items[i]))
      puts "Item #{i+1} #{items[i]['sku']}"
    end
  end

end