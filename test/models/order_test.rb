require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  test "status_timestamp" do
    store = Store.new
    order_hash = {
      'received_at' => '2013-02-25T17:15:22-03:00',
      'confirmed_at' => nil,
      'canceled_at' => '2013-02-25T17:28:56-03:00',
    }
    assert_equal(1361823322, Order.new(store, OrderStatus.received, order_hash).status_timestamp)
    assert_equal(1361823322, Order.new(store, OrderStatus.confirmed, order_hash).status_timestamp)
    assert_equal(1361824136, Order.new(store, OrderStatus.canceled, order_hash).status_timestamp)
  end

  test "km_record_event_url" do
    store = stores(:bodystore)
    order_hash = {
      'id' => 11263,
      'code' => 'F6D84B780B',
      'first_name' => 'Rafael',
      'last_name' => 'Souza',
      'email' => 'rafael.ssouza@gmail.com',
      'city' => 'São Borja',
      'state' => 'RS',
      'client_id' => '3',
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
      'updated_at' => '2013-02-25T17:28:56-03:00'
    }
    url = Order.new(store, OrderStatus.received, order_hash).km_record_event_url
    assert_match(/[&\?]order_total=58.9/, url)
    assert_match(/[&\?]City=S%C3%A3o%20Borja/, url)
    assert_match(/[&\?]State=RS/, url)
    assert_match(/[&\?]Received%20Items%20Quantity=1/, url)
    assert_match(/[&\?]_p=rafael.ssouza%40gmail.com/, url)
    url = Order.new(store, OrderStatus.canceled, order_hash).km_record_event_url
    assert_match(/[&\?]canceled_total=58.9/, url)
    assert_match(/[&\?]Canceled%20Items%20Quantity=1/, url)
    url = Order.new(store, OrderStatus.confirmed, order_hash).km_record_event_url
    assert_match(/[&\?]billing_amout=58.9/, url)
    assert_match(/[&\?]Confirmed%20Items%20Quantity=1/, url)
  end

  test "km_record_event_url with multiple items" do
    store = stores(:bodystore)
    order_hash = {
      'total' => 130.0,
      'items' => [
        {
          "quantity" => 2,
          "subtotal" => 20.0,
          "total" => 40.0
        },
        {
          "quantity" => 3,
          "subtotal" => 30.0,
          "total" => 90.0
        }
      ],
      'received_at' => '2013-02-25T17:15:22-03:00',
    }
    url = Order.new(store, OrderStatus.received, order_hash).km_record_event_url
    assert_match(/[&\?]Received%20Items%20Quantity=5/, url)
  end

  test "km_set_item_properites_url" do
    store = stores(:bodystore)
    order_hash = {
      'id' => 11263,
      'code' => 'F6D84B780B',
      'first_name' => 'Rafael',
      'last_name' => 'Souza',
      'email' => 'rafael.ssouza@gmail.com',
      'client_id' => '3',
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
    order = Order.new(store, OrderStatus.received, order_hash)
    url = order.km_set_item_properites_url(1, order.items.first)
    assert_match(/[&\?]Received%20Item%5B1%5D%5BSKU%5D=1816/, url)
    order = Order.new(store, OrderStatus.canceled, order_hash)
    url = order.km_set_item_properites_url(1, order.items.first)
    assert_match(/[&\?]Canceled%20Item%5B1%5D%5BSKU%5D=1816/, url)
    order = Order.new(store, OrderStatus.confirmed, order_hash)
    url = order.km_set_item_properites_url(1, order.items.first)
    assert_match(/[&\?]Confirmed%20Item%5B1%5D%5BSKU%5D=1816/, url)
  end

end