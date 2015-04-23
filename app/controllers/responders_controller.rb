class RespondersController < ApplicationController
  respond_to :json
  before_action :find_responder, only: [:show, :update]
  before_action :render_404, only: [:new, :edit, :destroy]

  def index
    if params[:show] == 'capacity'
      @capacity = {}
      @capacity['Fire'] = capacitate 'Fire'
      @capacity['Police'] = capacitate 'Police'
      @capacity['Medical'] = capacitate 'Medical'
    end
    @responders = Responder.all
  end

  def show
  end

  def create
    @responder = Responder.new params.require(:responder).permit(:name, :type, :capacity)
    if @responder.save
      render :show, status: :created
    else
      @message = { message: @responder.errors }
      render json: @message, status: :unprocessable_entity
    end
  end

  def new
  end

  def edit
  end

  def update
    render :show if @responder.update(params.require(:responder).permit(:on_duty))
  end

  def destroy
  end

  private

  def capacitate(type)
    [Responder.where(type: type).sum(:capacity),
     Responder.where(type: type, emergency_code: nil).sum(:capacity),
     Responder.where(type: type, on_duty: true).sum(:capacity),
     Responder.where(type: type, on_duty: true, emergency_code: nil).sum(:capacity)]
  end

  def find_responder
    @responder = Responder.find_by_name! params[:name]
  end
end
