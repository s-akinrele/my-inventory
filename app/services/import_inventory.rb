class ImportInventory
  def initialize(file_path)
    @file_path = file_path
  end

  def call
    CSV.foreach(@file_path, headers: true) do |row|
      product = Product.find_or_initialize_by(sku: row['SKU'])
      product.title = row['Title']
      product.description = row['Description']
      product.price = row['Price']
      product.vendor = Vendor.find_or_create_by(name: row['Vendor'])
      product.save!
    end
  end
end
