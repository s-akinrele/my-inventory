class ImportsController < ApplicationController
  before_action :set_import_service

  def index
    @queue_stats = @import_service.queue_stats
    render json: @queue_stats
  end

  def create
    file_path = params[:file_path]
    
    if file_path.blank?
      render json: { error: 'File path is required' }, status: :bad_request
      return
    end

    unless File.exist?(file_path)
      render json: { error: 'File not found' }, status: :not_found
      return
    end

    result = @import_service.import_single_file(file_path)
    render json: result, status: :accepted
  end

  def batch_create
    file_paths = params[:file_paths]
    
    if file_paths.blank? || !file_paths.is_a?(Array)
      render json: { error: 'File paths array is required' }, status: :bad_request
      return
    end

    # Validate all files exist
    missing_files = file_paths.reject { |path| File.exist?(path) }
    if missing_files.any?
      render json: { error: "Files not found: #{missing_files.join(', ')}" }, status: :not_found
      return
    end

    result = @import_service.import_batch_files(file_paths)
    render json: result, status: :accepted
  end

  def status
    job_id = params[:job_id]
    batch_id = params[:batch_id]
    
    if job_id.present?
      result = @import_service.get_job_status(job_id)
    elsif batch_id.present?
      result = @import_service.get_batch_status(batch_id)
    else
      render json: { error: 'Job ID or Batch ID is required' }, status: :bad_request
      return
    end

    render json: result
  end

  def results
    batch_id = params[:batch_id]
    
    if batch_id.blank?
      render json: { error: 'Batch ID is required' }, status: :bad_request
      return
    end

    result = @import_service.get_all_batch_results(batch_id)
    render json: result
  end

  def cancel
    job_id = params[:job_id]
    
    if job_id.blank?
      render json: { error: 'Job ID is required' }, status: :bad_request
      return
    end

    result = @import_service.cancel_job(job_id)
    render json: result
  end

  private

  def set_import_service
    @import_service = SidekiqImportService.new
  end
end 