class CreateVendors < ActiveRecord::Migration[8.0]
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.string :website

      t.timestamps
    end
    add_index :vendors, :email, unique: true
  end
end
