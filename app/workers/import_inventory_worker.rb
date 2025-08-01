class ImportInventoryWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(file_path, tracking_job_id = nil, batch_id = nil)
    Rails.logger.info "Starting import job for file: #{file_path}"

    importer = ImportInventory.new(file_path)
    success = importer.process_csv

    # Store results for both single and batch imports
    job_id = batch_id || tracking_job_id || Digest::MD5.hexdigest("#{file_path}:#{Time.current.to_i}")
    store_job_results(job_id, importer.stats, importer.errors, success)

    if batch_id
      update_batch_progress(batch_id, importer.stats, importer.errors, success)
    end

    Rails.logger.info "Import job completed. Success: #{success}, Created: #{importer.stats[:created]}, Updated: #{importer.stats[:updated]}, Failed: #{importer.stats[:failed]}"

    # Only raise exception if no rows were processed at all (complete failure)
    # Validation errors are expected and should not cause the job to fail
    if importer.stats[:total_rows] == 0
      raise "Import failed completely - no rows processed"
    elsif !success && importer.errors.count > 0
      Rails.logger.warn "Import completed with #{importer.errors.count} validation errors"
    end
  end

  private

    def store_job_results(job_id, stats, errors, success)
    redis = Sidekiq.redis { |conn| conn }
    results_key = "import_results:#{job_id}"

    redis.multi do |multi|
      multi.hset(results_key, "success", success.to_s)
      multi.hset(results_key, "stats", stats.to_json)
      multi.hset(results_key, "errors", errors.to_json)
      multi.hset(results_key, "completed_at", Time.current.iso8601)
      multi.expire(results_key, 1.hour.to_i)
    end
  end

  def update_batch_progress(batch_id, stats, errors, success)
    redis = Sidekiq.redis { |conn| conn }
    batch_key = "import_batch:#{batch_id}"
    results_key = "import_results:#{batch_id}"

    # Store individual job results
    redis.multi do |multi|
      multi.hset(results_key, "success", success.to_s)
      multi.hset(results_key, "stats", stats.to_json)
      multi.hset(results_key, "errors", errors.to_json)
      multi.hset(results_key, "completed_at", Time.current.iso8601)
      multi.expire(results_key, 1.hour.to_i)

      # Increment completed jobs counter
      multi.hincrby(batch_key, "completed_jobs", 1)
    end

    # Check if all jobs in batch are complete
    total_jobs = redis.hget(batch_key, "total_jobs").to_i
    completed_jobs = redis.hget(batch_key, "completed_jobs").to_i

    if completed_jobs >= total_jobs
      redis.hset(batch_key, "status", "completed")
      redis.hset(batch_key, "completed_at", Time.current.iso8601)
      Rails.logger.info "Batch #{batch_id} completed with #{completed_jobs} jobs"
    end
  end
end
