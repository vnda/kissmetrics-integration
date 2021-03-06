class ProcessOrders

  def run
    stores.each do |store|
      puts store.domain
      OrderStatus.all.each do |order_status|
        begin
          last_order_date = store.last_order_date(order_status)
          min_updated_at = nil
          new_last_order_date = nil
          begin
            last_min_updated_at = min_updated_at
            orders = store.get_orders(order_status, min_updated_at)
            break if orders.empty?
            orders.each do |order|
              if send_km_event?(order, last_order_date)
                order.km_event
                new_last_order_date = order.status_date if new_last_order_date.nil? || new_last_order_date < order.status_date
              end
              min_updated_at = order.updated_at if min_updated_at.nil? || order.updated_at > min_updated_at
            end
            # Evita entrar em loop infinito caso min_updated_at não tenha mudado
            raise 'Mesmo min_updated_at' if last_min_updated_at == min_updated_at
          end while true
          store.set_last_order_date(order_status, new_last_order_date) unless new_last_order_date.nil?
        rescue => e
          Raven.capture_exception(e)
          puts e
        end
      end
      puts
    end
  end

  # Não envia ao KM pedidos que foram muito recentemente recebidos/confirmados/cancelados
  # Isso evita o seguinte cenário:
  # 1) O script inicia e processa algumas páginas de pedidos.
  # 2) Enquanto isso, um pedido com id alto é confirmado.
  # Este pedido não será processado pois estaria primeiras páginas que já foram processadas.
  # 3) Em seguida outro pedido é confirmado, mas este pedido é mais antigo e tem um id baixo.
  # Então o script encontra esse pedido e envia ao KM. E usa a data de confirmação desse
  # pedido como sendo o mais recente processado e o pedido anterior não será processado na
  # próxima execução do script.
  def send_km_event?(order, last_order_date)
    order.status_date < max_date_to_process && (
      last_order_date.nil? ||
      order.status_date > last_order_date
    )
  end
  
  def max_date_to_process
    @max_date_to_process ||= 30.minutes.ago
  end
  
  def stores
    Store.where(active: true)
  end

end