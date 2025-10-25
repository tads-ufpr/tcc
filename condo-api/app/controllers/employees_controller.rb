class EmployeesController < ApplicationController
  load_and_authorize_resource :employee, only: [:show, :update, :destroy]

  def index
  end

  def show
  end

  def create
  end

  def update
  end

  def delete
  end
end
