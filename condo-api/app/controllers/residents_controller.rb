class ResidentsController < ApplicationController
  load_and_authorize_resource :apartment, only: [:create, :update, :destroy] # This was already there
  load_and_authorize_resource :resident, through: :apartment, shallow: true, only: [:create, :update, :destroy]
  load_and_authorize_resource :resident, only: [:show]

  def show
    render json: @resident, serializer: ResidentShowSerializer
  end

  # POST /apartments/:apartment_id/residents
  def create
    if @resident.save
      render json: @resident, serializer: ResidentSerializer, status: :created
    else
      render json: @resident.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /residents/:id
  def update
    if @resident.update(resident_params)
      render json: @resident, serializer: ResidentSerializer
    else
      render json: @resident.errors, status: :unprocessable_entity
    end
  end

  # DELETE /residents/:id
  def destroy
    @resident.destroy
  end

  private

  def resident_params
    case action_name
    when "create"
      params.require(:resident).permit(:user_id)
    when "update"
      params.require(:resident).permit(:owner)
    end
  end
end
