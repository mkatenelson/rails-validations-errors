class AirplanesController < ApplicationController
  def index
    @airplanes = Airplane.all
  end

  def new
    @airplane = Airplane.new
  end

  def create
    airplane = Airplane.new(airplane_params)
    if airplane.save
      redirect_to airplane_path(airplane)
    else
      redirect_to new_airplane_path
    end  
  end

  def show
    @airplane = Airplane.find(params[:id])
  end

  def airplane_params
    params.require(:airplane).permit(:name, :description)
  end
end
