#!/usr/bin/env ruby

# Test script for Sidekiq Batch Import functionality
require_relative 'config/environment'

puts "Testing Sidekiq Batch Import functionality..."
puts "=" * 60

# Initialize the import service
import_service = SidekiqImportService.new

# Test 1: Single file import
puts "\n1. Testing single file import..."
single_result = import_service.import_single_file('product_import.csv')
puts "Single import result: #{single_result}"

# Test 2: Batch file import (multiple files)
puts "\n2. Testing batch file import..."
batch_files = [ 'product_import.csv' ] # Add more files as needed
batch_result = import_service.import_batch_files(batch_files)
puts "Batch import result: #{batch_result}"

# Test 3: Check queue stats
puts "\n3. Checking queue stats..."
stats = import_service.queue_stats
puts "Queue stats: #{stats}"

# Test 4: Monitor single job status
if single_result[:job_id]
  puts "\n4. Monitoring single job status..."
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

# Test 5: Monitor batch status
if batch_result[:batch_id]
  puts "\n5. Monitoring batch status..."
  10.times do |i|
    status = import_service.get_batch_status(batch_result[:batch_id])
    puts "Batch status (attempt #{i + 1}): #{status[:status]} - Progress: #{status[:progress]}% (#{status[:completed_jobs]}/#{status[:total_jobs]})"

    if status[:status] == 'completed'
      puts "Batch completed!"

      # Get detailed batch results
      results = import_service.get_all_batch_results(batch_result[:batch_id])
      puts "Batch results: #{results}"
      break
    end

    sleep 3
  end
end

puts "\n" + "=" * 60
puts "Sidekiq batch import test completed!"
puts "\nTo start Sidekiq workers, run: bundle exec sidekiq"
puts "To view Sidekiq web interface, add to Gemfile: gem 'sidekiq-web'"
puts "\nAPI Endpoints:"
puts "- POST /imports - Single file import"
puts "- POST /imports/batch_create - Multiple files"
puts "- GET /imports/status?job_id=xxx - Check job status"
puts "- GET /imports/status?batch_id=xxx - Check batch status"
puts "- GET /imports/results?batch_id=xxx - Get batch results"
