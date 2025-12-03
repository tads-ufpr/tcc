class EmployeesController < ApplicationController
  load_and_authorize_resource :condominium, only: [:create, :index]
  load_and_authorize_resource :employee, only: [:show, :update, :destroy]

  wrap_parameters :employee, include: [:user_id, :email, :description, :role]

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

    @employee = @condominium.employees.build(employee_params.except(:email, :user_id).merge(user:))

    if @employee.save
      render json: @employee, status: :created
    else
      render_error(@employee.errors, :unprocessable_content)
    end
  end

  def update
    if @employee.update(employee_params)
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
    return User.find_by(email: employee_params[:email]) if employee_params[:email]

    User.find_by(id: employee_params[:user_id]) if employee_params[:user_id]
  end

  def employee_params
    params.require(:employee).permit(:role, :user_id, :email, :description)
  end
end
