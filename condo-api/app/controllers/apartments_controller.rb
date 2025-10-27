class ApartmentsController < ApplicationController
  load_and_authorize_resource

  # GET /apartments
  def index
    @apartments = Apartment.all

    render json: @apartments
  end

  # GET /apartments/1
  def show
    render json: @apartment
  end

  # POST /apartments
  def create
    @apartment = Apartment.new(apartment_params)

    if @apartment.save
      render json: @apartment, status: :created, location: @apartment
    else
      render_errors(@apartment.errors, :unprocessable_content)
    end
  end

  # PATCH/PUT /apartments/1
  def update
    if @apartment.update(apartment_params)
      render json: @apartment
    else
      render_errors(@apartment.errors, :unprocessable_content)
    end
  end

  # DELETE /apartments/1
  def destroy
    @apartment.destroy!
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_apartment
    @apartment = Apartment.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def apartment_params
    params.expect(apartment: [ :floor, :door, :tower, :rented, :active ])
  end
end
