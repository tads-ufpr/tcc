class ResidentsController < ApplicationController
  load_and_authorize_resource :apartment, only: [:index, :create]
  load_and_authorize_resource :resident, through: :apartment, shallow: true, only: [:index]
  load_and_authorize_resource :resident, only: [:show, :update, :destroy]


  # GET /apartments/:apartment_id/residents
  def index
    render json: @residents, each_serializer: ResidentSerializer
  end

  # GET /residents/:id
  def show
    render json: @resident, serializer: ResidentShowSerializer
  end

  # POST /apartments/:apartment_id/residents
  def create
    authorize! :create, Resident

    user = User.find_by(email: resident_params[:email])

    if user.blank?
      return render_error({ email: "not registered" }, :unprocessable_content)
    end

    @resident = @apartment.residents.build(user:)

    if @resident.save
      render json: @resident, serializer: ResidentSerializer, status: :created
    else
      render_error(@resident.errors, :unprocessable_content)
    end
  end

  # PATCH/PUT /residents/:id
  def update
    if @resident.update(resident_params)
      render json: @resident, serializer: ResidentSerializer
    else
      render_error(@resident.errors, :unprocessable_content)
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
      params.permit(:email)
    when "update"
      params.require(:resident).permit(:owner)
    end
  end
end
