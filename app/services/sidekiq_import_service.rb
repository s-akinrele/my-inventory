class SidekiqImportService
  def initialize
    @redis = Sidekiq.redis { |conn| conn }
  end

  # Start a single file import
  def import_single_file(file_path)
    Rails.logger.info "Queuing single file import: #{file_path}"

    # Generate a consistent job ID for tracking
    tracking_job_id = Digest::MD5.hexdigest("#{file_path}:#{Time.current.to_i}")
    
    # Pass the tracking job ID to the worker
    sidekiq_job_id = ImportInventoryWorker.perform_async(file_path, tracking_job_id)

    {
      job_id: tracking_job_id,
      sidekiq_job_id: sidekiq_job_id,
      file_path: file_path,
      status: "queued",
      queued_at: Time.current.iso8601
    }
  end

  # Start a batch import for multiple files using Sidekiq batching
  def import_batch_files(file_paths)
    Rails.logger.info "Queuing batch import for #{file_paths.count} files"

    # Generate a batch ID first
    batch_id = SecureRandom.uuid
    
    # Pass the batch ID to the coordinator
    sidekiq_job_id = ImportBatchCoordinatorWorker.perform_async(file_paths, batch_id)

    {
      batch_id: batch_id,
      sidekiq_job_id: sidekiq_job_id,
      file_count: file_paths.count,
      file_paths: file_paths,
      status: "queued",
      queued_at: Time.current.iso8601
    }
  end

  # Get job status
  def get_job_status(job_id)
    # Check if job completed (results stored in Redis)
    batch_results = get_batch_results(job_id)
    return batch_results if batch_results[:status] != "not_found"

    # For Sidekiq 8, we'll rely on Redis-based tracking
    # Check if job is in Redis queue
    redis = Sidekiq.redis { |conn| conn }
    queue_jobs = redis.lrange("queue:default", 0, -1)
    queued = queue_jobs.any? { |job| job.include?(job_id) }
    return { status: "queued", job_id: job_id } if queued

    # Check if job is processing (simplified for Sidekiq 8)
    workers = redis.smembers("workers")
    processing = workers.any? { |worker| worker.include?(job_id) }
    return { status: "processing", job_id: job_id } if processing

    { status: "not_found", job_id: job_id }
  end

  # Get batch status
  def get_batch_status(batch_id)
    batch_key = "import_batch:#{batch_id}"
    batch_data = @redis.hgetall(batch_key)

    if batch_data.empty?
      return { status: "not_found", batch_id: batch_id }
    end

    {
      status: batch_data["status"],
      batch_id: batch_id,
      total_jobs: batch_data["total_jobs"].to_i,
      completed_jobs: batch_data["completed_jobs"].to_i,
      progress: calculate_progress(batch_data["total_jobs"].to_i, batch_data["completed_jobs"].to_i),
      created_at: batch_data["created_at"],
      completed_at: batch_data["completed_at"]
    }
  end

  # Get batch results
  def get_batch_results(batch_id)
    results_key = "import_results:#{batch_id}"
    results = @redis.hgetall(results_key)

    if results.empty?
      return { status: "not_found", batch_id: batch_id }
    end

    {
      status: "completed",
      batch_id: batch_id,
      success: results["success"] == "true",
      stats: parse_json_safely(results["stats"]),
      errors: parse_json_safely(results["errors"]),
      completed_at: results["completed_at"]
    }
  end

  # Get all batch results
  def get_all_batch_results(batch_id)
    batch_status = get_batch_status(batch_id)
    return batch_status if batch_status[:status] == "not_found"

    # For batch jobs, the batch_id itself is used as the job_id for storing results
    # So we can get the batch results directly
    batch_results = get_batch_results(batch_id)

    {
      batch_status: batch_status,
      job_results: [batch_results],
      summary: summarize_batch_results([batch_results])
    }
  end

  # Cancel a job
  def cancel_job(job_id)
    redis = Sidekiq.redis { |conn| conn }

    # Remove from queue if present
    queue_jobs = redis.lrange("queue:default", 0, -1)
    queue_jobs.each_with_index do |job, index|
      if job.include?(job_id)
        redis.lrem("queue:default", 1, job)
        return { status: "cancelled", job_id: job_id }
      end
    end

    { status: "not_found", job_id: job_id }
  end

  # Get queue statistics
  def queue_stats
    redis = Sidekiq.redis { |conn| conn }

    # Get queue size
    queued_jobs = redis.llen("queue:default")

    # Get processed and failed counts from Redis
    processed_jobs = redis.get("stat:processed").to_i
    failed_jobs = redis.get("stat:failed").to_i

    # Get active workers count
    workers = redis.scard("workers")

    {
      queued_jobs: queued_jobs,
      queue_name: "default",
      processed_jobs: processed_jobs,
      failed_jobs: failed_jobs,
      workers: workers
    }
  end

  private

  def parse_json_safely(json_string)
    return nil if json_string.nil? || json_string.empty?
    JSON.parse(json_string)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse JSON: #{e.message}, JSON string: #{json_string}"
    nil
  end

  def calculate_progress(total, completed)
    return 0 if total.zero?
    ((completed.to_f / total) * 100).round(2)
  end

  def summarize_batch_results(job_results)
    total_created = job_results.sum { |result| result[:stats]&.dig("created") || 0 }
    total_updated = job_results.sum { |result| result[:stats]&.dig("updated") || 0 }
    total_failed = job_results.sum { |result| result[:stats]&.dig("failed") || 0 }
    total_errors = job_results.sum { |result| result[:errors]&.count || 0 }

    {
      total_created: total_created,
      total_updated: total_updated,
      total_failed: total_failed,
      total_errors: total_errors,
      success_rate: job_results.count { |result| result[:success] }.to_f / job_results.count * 100
    }
  end
end
