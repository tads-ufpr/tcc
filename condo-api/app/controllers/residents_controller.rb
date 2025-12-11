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

    user = find_user

    return render_user_not_found unless user

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

  def find_user
    if resident_params[:user_id]
      User.find_by(id: resident_params[:user_id])
    elsif resident_params[:email]
      User.find_by(email: resident_params[:email])
    end
  end

  def render_user_not_found
    error_key = resident_params[:user_id] ? :user_id : :email
    render_error({ error_key => "not found" }, :not_found)
  end

  def resident_params
    case action_name
    when "create"
      params.permit(:email, :user_id)
    when "update"
      params.require(:resident).permit(:owner)
    end
  end
end
