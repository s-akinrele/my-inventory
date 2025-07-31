require 'csv'

class ImportInventory
  EXPECTED_HEADERS = ['title', 'description', 'price', 'vendor_id', 'sku']

  attr_reader :errors, :stats

  def initialize(file_path)
    @file_path = file_path
    @errors = []
    @stats = {
      total_rows: 0,
      created: 0,
      updated: 0,
      failed: 0,
      skipped: 0
    }
  end

  def process_csv
    return false unless validate_csv(@file_path)
    call
    @errors.empty?
  end

  def validate_csv(file_path)
    unless File.exist?(file_path)
      @errors << "File not found: #{file_path}"
      return false
    end

    unless File.extname(file_path) == '.csv'
      @errors << "File must be a CSV file"
      return false
    end

    actual_headers = File.open(file_path).first.strip.split(',')
    unless actual_headers == EXPECTED_HEADERS
      @errors << "Invalid headers. Expected: #{EXPECTED_HEADERS.join(', ')}, Got: #{actual_headers.join(', ')}"
      return false
    end

    true
  end

  def call
    CSV.foreach(@file_path, headers: true).with_index(1) do |row, line_number|
      @stats[:total_rows] += 1

      begin
        process_row(row, line_number)
      rescue => e
        handle_row_error(e, row, line_number)
      end
    end

    # Process any remaining bulk operations
    process_bulk_operations

    log_summary
  end

  private

  def process_row(row, line_number)
    # Validate row data
    validation_errors = validate_row(row, line_number)
    if validation_errors.any?
      @errors.concat(validation_errors)
      @stats[:failed] += 1
      return
    end

    # Prepare product data
    product_data = build_product_data(row)
    
    # Check for existing product
    existing_product = Product.find_by(sku: row['sku'])
    
    if existing_product
      existing_product.assign_attributes(product_data)
      @products_to_update ||= []
      @products_to_update << existing_product
    else
      @products_to_create ||= []
      @products_to_create << Product.new(product_data)
    end
    
    # Process in chunks
    if (@products_to_create&.size || 0) + (@products_to_update&.size || 0) >= 1000
      process_bulk_operations
    end
  end

  def validate_row(row, line_number)
    errors = []

    # Check required fields
    errors << "Line #{line_number}: Missing title" if row['title'].blank?
    errors << "Line #{line_number}: Missing description" if row['description'].blank?
    errors << "Line #{line_number}: Missing SKU" if row['sku'].blank?
    errors << "Line #{line_number}: Missing vendor_id" if row['vendor_id'].blank?
    
    # Validate price
    if row['price'].present?
      begin
        price = BigDecimal(row['price'])
        if price < 0
          errors << "Line #{line_number}: Price cannot be negative"
        end
      rescue ArgumentError
        errors << "Line #{line_number}: Invalid price format: #{row['price']}"
      end
    else
      errors << "Line #{line_number}: Missing price"
    end

    # Validate vendor_id
    if row['vendor_id'].present?
      begin
        vendor_id = Integer(row['vendor_id'])
        unless Vendor.exists?(vendor_id)
          errors << "Line #{line_number}: Vendor with ID #{vendor_id} does not exist"
        end
      rescue ArgumentError
        errors << "Line #{line_number}: Invalid vendor_id format: #{row['vendor_id']}"
      end
    end

    # Validate SKU format
    if row['sku'].present?
      unless row['sku'].match?(/\A[A-Z0-9]+(?:-[A-Z0-9]+)*\z/)
        errors << "Line #{line_number}: Invalid SKU format: #{row['sku']}"
      end
    end

    errors
  end

  def build_product_data(row)
    {
      title: row['title'].strip,
      description: row['description'].strip,
      price: BigDecimal(row['price']),
      vendor_id: Integer(row['vendor_id']),
      sku: row['sku'].strip
    }
  end

  def process_bulk_operations
    return unless @products_to_create || @products_to_update

    begin
      # Bulk create new products
      if @products_to_create&.any?
        Product.import(@products_to_create, validate: false)
        @stats[:created] += @products_to_create.size
        puts "Created #{@products_to_create.size} products"
      end
      
      # Bulk update existing products
      if @products_to_update&.any?
        @products_to_update.each_slice(100) do |update_chunk|
          Product.import(update_chunk, on_duplicate_key_update: [:title, :description, :price, :vendor_id], validate: false)
        end
        @stats[:updated] += @products_to_update.size
        puts "Updated #{@products_to_update.size} products"
      end

    rescue => e
      handle_bulk_error(e)
    ensure
      @products_to_create = []
      @products_to_update = []
    end
  end

  def handle_row_error(error, row, line_number)
    error_message = "Line #{line_number}: Unexpected error processing row: #{error.message}"
    @errors << error_message
    @stats[:failed] += 1
    puts "ERROR: #{error_message}"
    puts "Row data: #{row.to_h}"
  end

  def handle_bulk_error(error)
    error_message = "Bulk operation failed: #{error.message}"
    @errors << error_message
    @stats[:failed] += (@products_to_create&.size || 0) + (@products_to_update&.size || 0)
    puts "ERROR: #{error_message}"
  end

  def log_summary
    puts "\n=== Import Summary ==="
    puts "Total rows processed: #{@stats[:total_rows]}"
    puts "Products created: #{@stats[:created]}"
    puts "Products updated: #{@stats[:updated]}"
    puts "Products failed: #{@stats[:failed]}"
    puts "Products skipped: #{@stats[:skipped]}"

    if @errors.any?
      puts "\n=== Errors ==="
      @errors.each { |error| puts "- #{error}" }
    end
  end
end
