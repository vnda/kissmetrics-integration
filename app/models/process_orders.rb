class ProcessOrders

  def run
    Store.all.each do |store|
      puts store.domain
      OrderStatus.all.each do |order_status|
        begin
          last_order_id = store.last_order_id(order_status)
          since_order_id = nil
          new_last_order_id = nil
          begin
            orders = store.get_orders(order_status, since_order_id)
            orders.each do |order|
              store.km_event(order, order_status) unless last_order_id && order['id'] <= last_order_id
              since_order_id = order['id'] if since_order_id.nil? || order['id'] < since_order_id
              new_last_order_id = order['id'] if new_last_order_id.nil? || new_last_order_id < order['id']
            end
          end while orders.any? && (last_order_id.nil? || since_order_id > last_order_id)
          store.set_last_order_id(order_status, new_last_order_id)
        rescue => e
          puts e
        end
      end
      puts
    end
  end

end