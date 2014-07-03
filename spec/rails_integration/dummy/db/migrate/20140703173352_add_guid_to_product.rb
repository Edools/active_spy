class AddGuidToProduct < ActiveRecord::Migration
  def change
    add_column :products, :guid, :string
  end
end
