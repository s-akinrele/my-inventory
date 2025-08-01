class ImportBatchCoordinatorWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

    def perform(file_paths, batch_id = nil)
    Rails.logger.info "Starting batch import coordination for #{file_paths.count} files"

    # Generate batch ID if not provided
    batch_id ||= SecureRandom.uuid

    # Store batch information
    store_batch_info(batch_id, file_paths)

    # Queue individual import jobs
    job_ids = file_paths.map do |file_path|
      ImportInventoryWorker.perform_async(file_path, nil, batch_id)
    end

    Rails.logger.info "Batch #{batch_id} queued with #{job_ids.count} jobs"
  end

  private

  def store_batch_info(batch_id, file_paths)
    redis = Sidekiq.redis { |conn| conn }
    key = "import_batch:#{batch_id}"

    redis.multi do |multi|
      multi.hset(key, "file_paths", file_paths.to_json)
      multi.hset(key, "total_jobs", file_paths.count)
      multi.hset(key, "completed_jobs", 0)
      multi.hset(key, "status", "processing")
      multi.hset(key, "created_at", Time.current.iso8601)
      multi.expire(key, 1.hour.to_i)
    end
  end
end
