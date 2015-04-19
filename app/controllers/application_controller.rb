class ApplicationController < ActionController::Base
  rescue_from ActionController::UnpermittedParameters, with: :unpermitted_params

  private

  def unpermitted_params(exception)
    render json: { message: exception.to_s }, status: 422
  end

end
