class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def create
    @user = User.new(user_params)

    if @user.save
      token = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil).first
      response.headers["Authorization"] = "Bearer #{token}"

      render :created, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def update
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :name, :document, :cpf, :birthdate
    )
  end
end
