#!/usr/bin/env ruby

# Test script for Sidekiq Import functionality
require_relative 'config/environment'

puts "Testing Sidekiq Import functionality..."
puts "=" * 60

# Initialize the import service
import_service = SidekiqImportService.new

# Test 1: Single file import
puts "\n1. Testing single file import..."
single_result = import_service.import_single_file('product_import.csv')
puts "Single import result: #{single_result}"

# Test 2: Batch file import
puts "\n2. Testing batch file import..."
batch_files = [ 'product_import.csv' ] # Add more files as needed
batch_result = import_service.import_batch_files(batch_files)
puts "Batch import result: #{batch_result}"

# Test 3: Check queue stats
puts "\n3. Checking queue stats..."
stats = import_service.queue_stats
puts "Queue stats: #{stats}"

# Test 4: Monitor job status (if job_id is available)
if single_result[:job_id]
  puts "\n4. Monitoring job status..."
  5.times do |i|
    status = import_service.get_job_status(single_result[:job_id])
    puts "Job status (attempt #{i + 1}): #{status[:status]}"

    if status[:status] == 'completed'
      puts "Job completed!"
      break
    end

    sleep 2
  end
end

# Test 5: Check batch status (if batch_id is available)
if batch_result[:batch_id]
  puts "\n5. Monitoring batch status..."
  5.times do |i|
    status = import_service.get_batch_status(batch_result[:batch_id])
    puts "Batch status (attempt #{i + 1}): #{status[:status]}"

    if status[:status] == 'completed'
      puts "Batch completed!"

      # Get batch results
      results = import_service.get_batch_results(batch_result[:batch_id])
      puts "Batch results: #{results}"
      break
    end

    sleep 3
  end
end

puts "\n" + "=" * 60
puts "Sidekiq import test completed!"
puts "\nTo start Sidekiq workers, run: bundle exec sidekiq"
puts "To view Sidekiq web interface, add to Gemfile: gem 'sidekiq-web'"
