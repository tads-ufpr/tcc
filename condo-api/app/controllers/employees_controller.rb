class EmployeesController < ApplicationController
  load_and_authorize_resource :condominium, only: [:create, :index]
  load_and_authorize_resource :employee, through: :condominium, only: [:create]
  load_and_authorize_resource :employee, only: [:show, :update, :destroy]

  def index
    authorize! :read_employees, @condominium

    @employees = @condominium.employees
                             .includes(:user)
                             .accessible_by(current_ability)
  end

  def show
  end

  def create
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
      render json: @employee.errors, status: :unprocessable_content
    end
  end

  def destroy
    @employee.destroy
  end

  private

  def employee_params
    params.require(:employee).permit(:role, :user_id, :description)
  end
end
