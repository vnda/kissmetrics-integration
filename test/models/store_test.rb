require 'test_helper'

class StoreTest < ActiveSupport::TestCase

  def setup
    @store = Store.new(
      domain: 'example.com',
      user: 'user123',
      pass: 'secret123',
    )
  end
  
  test "orders_api_url" do
    url = @store.orders_api_url(OrderStatus.received, DateTime.new(2013, 05, 05, 23, 03, 47, '-3'))
    assert_equal('http://user123:secret123@example.com/api/orders?status=received&min_updated_at=2013-05-05T23:03:47-03:00', url)
  end

  test "orders_api_url without min_updated_at" do
    url = @store.orders_api_url(OrderStatus.received)
    assert_equal('http://user123:secret123@example.com/api/orders?status=received', url)
  end
  
end