class AddActiveToStores < ActiveRecord::Migration
  def change
    add_column :stores, :active, :boolean, null: false, default: true
  end
end
