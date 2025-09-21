class CondominiaController < ApplicationController
  before_action :set_condominium, only: %i[ show update destroy ]
  skip_before_action :authenticate_user!, only: [:index]

  # GET /condominia
  def index
    @condominia = Condominium.all

    render json: @condominia
  end

  # GET /condominia/1
  def show
    render json: @condominium
  end

  # POST /condominia
  def create
    @condominium = Condominium.new(condominium_params)

    Condominium.transaction do
      if @condominium.save
        Employee.create!(user: current_user,
          condominium: @condominium,
          role: Employee::ROLES.first,
          descrsption: Employee::Default
        )

        render json: @condominium, status: :created, location: @condominium
      else
        render json: @condominium.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /condominia/1
  def update
    if @condominium.update(condominium_params)
      render json: @condominium
    else
      render json: @condominium.errors, status: :unprocessable_entity
    end
  end

  # DELETE /condominia/1
  def destroy
    @condominium.destroy!
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_condominium
    @condominium = Condominium.find(params.expect(:id))
  end

  def condominium_params
    params.require(:condominium)
      .permit(
        :name, :address, :city, :state,
        :neighborhood, :zipcode, :number
      )
  end
end
