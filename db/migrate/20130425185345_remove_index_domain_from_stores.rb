class RemoveIndexDomainFromStores < ActiveRecord::Migration
  def up
    remove_index :stores, :domain
  end

  def down
    add_index :stores, :domain, unique: true
  end
end
