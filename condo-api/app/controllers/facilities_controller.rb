class FacilitiesController < ApplicationController
  load_and_authorize_resource :condominium, only: %i[index create]
  load_and_authorize_resource :facility, through: :condominium, shallow: true

  def index
    render json: @facilities
  end

  def show
    render json: @facility
  end

  def create
    if @facility.save
      render json: @facility, status: :created, location: @facility
    else
      render json: @facility.errors, status: :unprocessable_entity
    end
  end

  def update
    if @facility.update(facility_params)
      render json: @facility
    else
      render json: @facility.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @facility.destroy
  end

  private

  def facility_params
    params.require(:facility).permit(:name, :description, :tax)
  end
end
