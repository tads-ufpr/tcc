class Apartments::ReservationsController < ApplicationController
  load_and_authorize_resource :apartment
  load_and_authorize_resource :reservation, through: :apartment

  def index
    reservations = @reservations.where("scheduled_date >= ?", Date.today).order(scheduled_date: :asc)
    render json: reservations
  end
end
