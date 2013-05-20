require 'test_helper'

# mocks

def OrderStatus.all
  [by_param('received')]
end

class OrderMock < Struct.new(:id, :status_date)
  def km_event
    @sent = true
  end
  def sent?
    @sent
  end
  def reset!
    @sent = false
  end
end

class StoreMock

  def initialize(orders)
    @orders = orders
    @orders.sort_by!{|order| order.id}
    @orders.reverse!    
  end
  
  def domain
    'storemock.example.com'
  end
  
  def orders
    @orders
  end
  
  def reset_orders
    orders.each do |order|
      order.reset!
    end
  end
  
  def get_orders(order_status, since_order_id)
    orders.select { |order| since_order_id.nil? || order.id < since_order_id }.take(3)
  end
  
  def set_last_order_date(order_status, new_last_order_date)
    @last_order_date = new_last_order_date
  end
  
  def last_order_date(order_status)
    @last_order_date
  end
  
end

class ProcessOrdersTest < ActiveSupport::TestCase
  
  def setup
    @orders = [
      OrderMock.new(101, DateTime.new(2013, 05, 19, 23, 59, 00)),
      OrderMock.new(102, DateTime.new(2013, 05, 20, 20, 45, 00)),
      OrderMock.new(103, DateTime.new(2013, 05, 20, 18, 30, 00)),
      OrderMock.new(104, DateTime.new(2013, 05, 20, 20, 29, 50)),
      OrderMock.new(105, DateTime.new(2013, 05, 20, 20, 35, 00)),
    ]
  end

  test "test get orders mock" do
    store = StoreMock.new(@orders)
    orders = store.get_orders(OrderStatus.received, nil)
    assert_equal(3, orders.size)
    assert_equal([105, 104, 103], orders.map(&:id))
    orders = store.get_orders(OrderStatus.received, 103)
    assert_equal(2, orders.size)
    assert_equal([102, 101], orders.map(&:id))
  end

  test "run" do
    process_orders = ProcessOrders.new
    store = StoreMock.new(@orders)
    process_orders.define_singleton_method(:stores) { [store] }
    
    process_orders.define_singleton_method(:max_date_to_process) { DateTime.new(2013, 5, 20, 20, 30, 00) }
    process_orders.run
    orders_hash = store.orders.index_by(&:id)
    assert(orders_hash[101].sent?)
    assert_not(orders_hash[102].sent?)
    assert(orders_hash[103].sent?)
    assert(orders_hash[104].sent?)
    assert_not(orders_hash[105].sent?)
    assert_equal(DateTime.new(2013, 05, 20, 20, 29, 50), store.last_order_date(OrderStatus.received))
    
    store.reset_orders
    process_orders.define_singleton_method(:max_date_to_process) { DateTime.new(2013, 5, 20, 20, 40, 00) }
    process_orders.run
    orders_hash = store.orders.index_by(&:id)
    assert_not(orders_hash[101].sent?)
    assert_not(orders_hash[102].sent?)
    assert_not(orders_hash[103].sent?)
    assert_not(orders_hash[104].sent?)
    assert(orders_hash[105].sent?)
    assert_equal(DateTime.new(2013, 05, 20, 20, 35, 00), store.last_order_date(OrderStatus.received))

    store.reset_orders
    process_orders.define_singleton_method(:max_date_to_process) { DateTime.new(2013, 5, 20, 20, 50, 00) }
    process_orders.run
    orders_hash = store.orders.index_by(&:id)
    assert_not(orders_hash[101].sent?)
    assert(orders_hash[102].sent?)
    assert_not(orders_hash[103].sent?)
    assert_not(orders_hash[104].sent?)
    assert_not(orders_hash[105].sent?)
    assert_equal(DateTime.new(2013, 05, 20, 20, 45, 00), store.last_order_date(OrderStatus.received))

    store.reset_orders
    process_orders.define_singleton_method(:max_date_to_process) { DateTime.new(2013, 5, 20, 21, 00, 00) }
    process_orders.run
    store.orders.each do |order|
      assert_not(order.sent?)
    end
    assert_equal(DateTime.new(2013, 05, 20, 20, 45, 00), store.last_order_date(OrderStatus.received))
  end

end