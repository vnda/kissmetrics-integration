class ChangeLastOrderIdToLastDate < ActiveRecord::Migration
  def change

    add_column :stores, :last_order_received_date, :datetime
    add_column :stores, :last_order_confirmed_date, :datetime
    add_column :stores, :last_order_canceled_date, :datetime

    remove_column :stores, :last_order_received_id
    remove_column :stores, :last_order_confirmed_id
    remove_column :stores, :last_order_canceled_id

  end
end
