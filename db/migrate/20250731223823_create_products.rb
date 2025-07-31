class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.references :vendor, null: false, foreign_key: true
      t.string :sku

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end
