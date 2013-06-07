class Order < Struct.new(
  :store,
  :id,
  :code,
  :token,
  :status,
  :first_name,
  :last_name,
  :email,
  :city,
  :state,
  :client_id,
  :slip,
  :slip_url,
  :payment_method,
  :shipping_price,
  :subtotal,
  :discount_price,
  :total,
  :items,
  :updated_at,
  :received_at,
  :confirmed_at,
  :canceled_at,
)

  def initialize(store, status, order_hash)
    self.store = store
    self.status = status
    order_hash.each_pair do |key, value|
      self[key] = value if members.include?(key.to_sym) && key != "status"
    end
  end

  # caso seja confirmado ou cancelado e não tenha a respectiva data, usa data de recebimento
  def status_date
    send(status.at) || received_at
  end

  def status_timestamp
    DateTime.strptime(status_date, '%Y-%m-%dT%H:%M:%S%:z').to_i if status_date
  end

  def km_api_key_person_parameters
    {
      '_k' => store.km_api_key,
      '_p' => email,
    }    
  end
  
  
  def km_api_main_parameters
    km_api_key_person_parameters.merge({
      '_t' => status_timestamp,
      '_d' => '1',
    })
  end

  # http://support.kissmetrics.com/apis/specifications.html#recording-an-event
  def km_record_event_url
    params = km_api_main_parameters.merge({
      '_n' => status.km_event,
      'OrderID' => id,
      'Order Code' => code,
      'City' => city,
      'State' => state,
      'Items Quantity' => items.inject(0) { |sum, item| sum + item['quantity'] },
      'Name' => "#{first_name} #{last_name}",
      'ClientId' => client_id,
      'Email' => email,
      'Payment Method' => payment_method,
      'Shipping Price' => shipping_price,
      'Subtotal' => subtotal,
      'Discount Price' => discount_price,
      status.km_total_property => total,
    })
    "http://trk.kissmetrics.com/e?#{params.to_query}"
  end
  
  def km_alias_user_url
    params = km_api_key_person_parameters.merge({'_n' => client_id})
    "http://trk.kissmetrics.com/a?#{params.to_query}"    
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
    raise "Identificador da pessoa (email) não pode ser vazio" if email.blank?
    RestClient.get_with_retry(km_alias_user_url) if client_id.present?
    RestClient.get_with_retry(km_record_event_url)
    puts "Order #{id} #{status.param} at #{status_date}."
    items.each_index do |i|
      RestClient.get_with_retry(km_set_item_properites_url(i+1, items[i]))
      puts "Item #{i+1} #{items[i]['sku']}"
    end
  end

end