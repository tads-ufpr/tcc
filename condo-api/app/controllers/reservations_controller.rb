class ReservationsController < ApplicationController
  load_and_authorize_resource :facility, only: [:index, :create]
  load_and_authorize_resource :reservation, through: :facility, only: [:index, :create]
  load_and_authorize_resource :reservation, only: [:destroy]

  def index
    reservations = if params[:until].present?
      @reservations.where("scheduled_date > ? AND scheduled_date < ?", params[:until].to_date, Date.today).order(scheduled_date: :desc)
    else
      @reservations.where("scheduled_date >= ?", Date.today).order(scheduled_date: :asc)
    end

    render json: reservations
  end

  def create
    @reservation.creator = current_user
    if @reservation.save
      render json: @reservation, status: :created
    else
      render_error(@reservation.errors, :unprocessable_content)
    end
  end

  def destroy
    if @reservation.destroy
      head :no_content
    else
      render_error(@reservation.errors, :unprocessable_content)
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:apartment_id, :scheduled_date)
  end
end
