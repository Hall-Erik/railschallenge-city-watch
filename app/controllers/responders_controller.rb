class RespondersController < ApplicationController
  respond_to :json
  before_action :find_responder, only: [:show, :edit, :update, :destroy]
  before_action :render_404, only: [:new, :edit, :destroy]

  def index
    @responders = Responder.all

    #render json: @responder.as_json(only: [:name, :type, :capacity])
  end

  def show

  end

  def create
    @responder = Responder.new responder_params

    if @responder.save
      @json = {responder: @responder.as_json(only: [:on_duty, :emergency_code, :capacity, :name, :type, :capacity])}
      render json: @json, status: 201
    else
      @message = {message: @responder.errors}
      render json: @message, status: 422
    end
  end

  def new
  end

  def edit
  end

  def destroy
  end

  private

  def render_404
    render file: "#{Rails.root}/public/404.json", layout: false, status: 404
  end

  def responder_params
    params.require(:responder).permit(:name, :type, :capacity)
  end

  def find_responder
    @responder = Responder.find_by(name: params[:name])
  end
end
