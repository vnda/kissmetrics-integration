class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :domain
      t.string :user
      t.string :pass
      t.string :km_api_key
      t.integer :last_order_received_id
      t.integer :last_order_confirmed_id
      t.integer :last_order_canceled_id

      t.index :domain, unique: true
    end
  end
end
