class CondominiaController < ApplicationController
  load_and_authorize_resource class: "Condominium"

  # GET /condominia
  def index
    @condominia = if params[:q].present?
      Condominium.where("
        name LIKE '%#{params[:q]}%' OR
        address LIKE '%#{params[:q]}%' OR
        city LIKE '%#{params[:q]}%' OR
        neighborhood LIKE '%#{params[:q]}%' OR
        zipcode LIKE '%#{params[:q]}%'
      ")
    else
      Condominium.all
    end

    render json: @condominia
  end

  # GET /condominia/1
  def show
    render json: @condominium, scope: current_ability
  end

  # POST /condominia
  def create
    @condominium = Condominium.new(condominium_params)

    Condominium.transaction do
      if @condominium.save
        Employee.create!(user: current_user,
          condominium: @condominium,
          role: :admin,
          description: Employee::Default
        )

        render json: @condominium,
          status: :created,
          location: @condominium,
          scope: current_ability
      else
        render_error(@condominium.errors, :unprocessable_content)
      end
    end
  end

  # PATCH/PUT /condominia/1
  def update
    if @condominium.update(condominium_params)
      render json: @condominium
    else
      render_error(@condominium.errors, :unprocessable_content)
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

  def read_options
    { include: [:apartments], params: { ability: current_ability } }
  end
end
