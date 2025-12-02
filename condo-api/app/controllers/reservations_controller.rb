class ReservationsController < ApplicationController
  load_and_authorize_resource :facility
  load_and_authorize_resource :reservation, through: :facility

  def create
    @reservation.creator = current_user
    if @reservation.save
      render json: @reservation, status: :created
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:apartment_id, :scheduled_date)
  end
end
