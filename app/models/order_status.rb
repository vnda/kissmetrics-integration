class OrderStatus < Struct.new(:param, :km_event, :at, :last_order_id_column, :km_total_property, :km_total_value_signal)

  STATUSES            = %w(   received    canceled     confirmed)
  KM_EVENTS           = %w(  purchased    canceled       billing)
  KM_TOTAL_PROPERTIES = %w(order_total order_total billing_amout)
  KM_TOTAL_VALUE_SIGNALS = [1, -1, 1]

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
    new(param, map_km_event[param], "#{param}_at", "last_order_#{param}_id", map_km_total_property[param], map_km_total_value_signal[param])
  end

  def self.map_km_event
    @map_km_event ||= Hash[STATUSES.zip(KM_EVENTS)]
  end

  def self.map_km_total_property
    @map_km_total_property ||= Hash[STATUSES.zip(KM_TOTAL_PROPERTIES)]
  end

  def self.map_km_total_value_signal
    @map_km_total_value ||= Hash[STATUSES.zip(KM_TOTAL_VALUE_SIGNALS)]
  end

  def total_value(value)
    value * km_total_value_signal
  end

end