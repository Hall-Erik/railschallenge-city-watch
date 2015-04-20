class ApplicationController < ActionController::Base
  rescue_from ActionController::UnpermittedParameters, with: :unpermitted_params
  rescue_from ActiveRecord::RecordNotFound, with: :no_record

  def render_404
    render file: "#{Rails.root}/public/404.json", layout: false, status: :not_found
  end

  private

  def unpermitted_params(exception)
    render json: { message: exception.to_s }, status: :unprocessable_entity
  end

  def no_record
    render_404
  end
end
