#!/usr/bin/env ruby

# Test script for ImportInventory error handling
require_relative 'config/environment'

puts "Testing ImportInventory error handling..."
puts "=" * 50

# Test 1: Valid import
puts "\n1. Testing valid import..."
importer = ImportInventory.new('product_import.csv')
success = importer.process_csv

puts "Success: #{success}"
puts "Stats: #{importer.stats}"
puts "Errors: #{importer.errors.count}"

# Test 2: Non-existent file
puts "\n2. Testing non-existent file..."
importer2 = ImportInventory.new('non_existent.csv')
success2 = importer2.process_csv

puts "Success: #{success2}"
puts "Errors: #{importer2.errors}"

# Test 3: Invalid headers
puts "\n3. Testing invalid headers..."
# Create a temporary file with wrong headers
File.write('temp_invalid.csv', "wrong,headers,here\nvalue1,value2,value3")
importer3 = ImportInventory.new('temp_invalid.csv')
success3 = importer3.process_csv

puts "Success: #{success3}"
puts "Errors: #{importer3.errors}"

# Clean up
File.delete('temp_invalid.csv') if File.exist?('temp_invalid.csv')

puts "\n" + "=" * 50
puts "Error handling test completed!"
