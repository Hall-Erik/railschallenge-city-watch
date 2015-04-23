class EmergenciesController < ApplicationController
  before_action :find_emergency, only: [:show, :update]
  before_action :render_404, only: [:new, :edit, :destroy]

  def index
    @emergencies = Emergency.all
    @full_response_count = [Emergency.where(full_response: true).count, @emergencies.count]
  end

  def show
  end

  def create
    # RuboCop was not happy with the length of this line, so I made it two lines.
    emergency_params = params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
    @emergency = Emergency.new emergency_params
    if @emergency.save
      render :show, status: :created
    else
      @message = { message: @emergency.errors }
      render json: @message, status: :unprocessable_entity
    end
  end

  def new
  end

  def edit
  end

  def update
    emergency_params = params.require(:emergency).permit(
      :fire_severity, :police_severity, :medical_severity, :resolved_at)
    render :show if @emergency.update emergency_params
  end

  def destroy
  end

  private

  def find_emergency
    @emergency = Emergency.find_by_code! params[:code]
  end
end
