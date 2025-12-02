class ApartmentsController < ApplicationController
  load_and_authorize_resource :condominium, only: [:index, :create]
  load_and_authorize_resource :apartment, through: :condominium, only: [:index, :create]
  load_and_authorize_resource :apartment, only: [:show, :update, :destroy, :approve]

  # GET /condominia/:condominium_id/apartments
  def index
    @apartments = @condominium.apartments

    if params[:status].present?
      @apartments = @apartments.where(status: params[:status])
    end

    if params[:created_after].present?
      @apartments = @apartments.where("created_at >= ?", params[:created_after])
    end

    if params[:created_before].present?
      @apartments = @apartments.where("created_at <= ?", params[:created_before])
    end

    render json: @apartments
  end

  # GET /apartments/1
  def show
    render json: @apartment
  end

  # POST /condominia/:condominium_id/apartments
  def create
    @apartment = Apartment.new(apartment_params)

    Apartment.transaction do
      @condominium.apartments << @apartment
      if @apartment.save
        @apartment.residents << Resident.new(user: current_user)

        render json: @apartment, status: :created, location: @apartment
      else
        render_error(@apartment.errors, :unprocessable_content)
      end
    end
  end

  # PATCH/PUT /apartments/1
  def update
    if @apartment.update(apartment_params)
      render json: @apartment, include: []
    else
      render_error(@apartment.errors, :unprocessable_content)
    end
  end

  # DELETE /apartments/1
  def destroy
    @apartment.destroy!
  end

  def approve
    if @apartment.update(status: :approved)
      render json: @apartment
    else
      render_error(@apartment.errors, :unprocessable_content)
    end
  end

  private
  # Only allow a list of trusted parameters through.
  def apartment_params
    params.require(:apartment).permit([ :floor, :number, :tower ])
  end
end
