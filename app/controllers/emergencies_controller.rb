class EmergenciesController < ApplicationController
  before_action :find_emergency, only: [:show, :update]
  before_action :render_404, only: [:new, :edit, :destroy]

  def show
  end

  def create
    @emergency = Emergency.new params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
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

  def destroy
  end

  private

  def find_emergency
    @emergency = Emergency.find_by_code params[:code]
  end
end
