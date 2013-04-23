require 'test_helper'

class StoreTest < ActiveSupport::TestCase

  test "time" do
    store = Store.new
    order = {
      'received_at' => '2013-02-25T17:15:22-03:00',
      'confirmed_at' => nil,
      'canceled_at' => '2013-02-25T17:28:56-03:00',
    }
    assert_equal(1361823322, store.order_timestamp(order, OrderStatus.received))
    assert_nil(store.order_timestamp(order, OrderStatus.confirmed))
    assert_equal(1361824136, store.order_timestamp(order, OrderStatus.canceled))
  end

  test "km_event" do
    store = stores(:bodystore)
    order = {
      'id' => 11263,
      'code' => 'F6D84B780B',
      'first_name' => 'Rafael',
      'last_name' => 'Souza',
      'email' => 'rafael.ssouza@gmail.com',
      'client_id' => "3",
      'slip' => false,
      'slip_url' => nil,
      'payment_method' => 'Cartão de Crédito (Visa)',
      'shipping_price' => 3.0,
      'subtotal' => 55.9,
      'discount_price' => '0.0',
      'total' => 58.9,
      'items' => [
        {
          "id" => 23650,
          "reference" => "1816",
          "sku" => "1816",
          "quantity" => 1,
          "subtotal" => 55.9,
          "total" => 55.9
        }
      ],
      'received_at' => '2013-02-25T17:15:22-03:00',
      'confirmed_at' => nil,
      'canceled_at' => '2013-02-25T17:28:56-03:00',
    }
    store.km_event(order, OrderStatus.received)
    store.km_event(order, OrderStatus.canceled)
  end

end
