class OrderStatus < Struct.new(:param, :km_event, :at, :last_order_id_column)

  STATUSES  = %w(received  canceled confirmed)
  KM_EVENTS = %w(purchased canceled billing)

  # Create methods OrderStatus.received, OrderStatus.canceled, etc
  STATUSES.each do |status|
    define_singleton_method(status) do
      by_param(status)
    end
  end

  def self.all
    @all ||= STATUSES.map { |param| by_param(param) }
  end

  def self.by_param(param)
    new(param, map_km_event[param], "#{param}_at", "last_order_#{param}_id")
  end

  def self.map_km_event
    @map_km_event ||= Hash[STATUSES.zip(KM_EVENTS)]
  end

end