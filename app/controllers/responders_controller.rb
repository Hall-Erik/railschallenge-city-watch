class RespondersController < ApplicationController
  respond_to :json
  before_action :find_responder, only: [:show, :edit, :update, :destroy]

  def index

  end

  def show

  end

  def create

  end

  def new
    render_404
  end

  def edit
    render_404
  end

  def destroy
    render_404
  end

  private

  def render_404
    render file: "#{Rails.root}/public/404.json", layout: false, status: 404
  end

  def responder_params
    params.require(:responder).permit(:name)
  end

  def find_responder
    @responder = Responder.find_by(name: params[:name])
  end
end
