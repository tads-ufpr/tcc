class EmployeesController < ApplicationController
  load_and_authorize_resource :condominium, only: [:create, :index]
  load_and_authorize_resource :employee, only: [:show, :update, :destroy]

  wrap_parameters :employee, include: [:user_id, :description, :role]

  def index
    authorize! :read_employees, @condominium

    @employees = @condominium.employees
                             .includes(:user)
                             .accessible_by(current_ability)
  end

  def show
  end

  def create
    authorize! :create_employee, @condominium
    user = find_user

    if user.blank?
      return render_error({ user: "unregistered user" }, :unprocessable_content)
    end

    @employee = Employee.new(employee_creation_params.slice(:role, :description))
    @employee.user = user
    @employee.condominium = @condominium

    if @employee.save
      render json: @employee, status: :created
    else
      render_error(@employee.errors, :unprocessable_content)
    end
  end

  def update
    if @employee.update(employee_update_params)
      render json: @employee
    else
      render_error(@employee.errors, :unprocessable_content)
    end
  end

  def destroy
    @employee.destroy
  end

  private

  def find_user
    user_credentials = employee_creation_params.slice(:email, :user_id)
    return User.find_by(email: user_credentials[:email]) if user_credentials[:email].present?

    User.find_by(id: user_credentials[:user_id]) if user_credentials[:user_id].present?
  end

  def employee_creation_params
    @employee_creation_params ||= params.require(:employee).permit(:email, :user_id, :role, :description)
  end

  def employee_update_params
    params.require(:employee).permit(:role, :description)
  end
end
