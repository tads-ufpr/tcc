class NoticesController < ApplicationController
  load_and_authorize_resource :apartment, only: [:create]
  load_and_authorize_resource :notice, through: :apartment, only: [:create]
  load_and_authorize_resource :notice, only: [:show, :update, :destroy]

  # GET /condominia/:condominium_id/notices
  # GET /apartments/:apartment_id/notices
  def index
    if params[:condominium_id].present?
      @condominium = Condominium.find(params[:condominium_id])
      authorize! :read_notices, @condominium

      @notices = Notice.joins(:apartment)
                       .where(apartments: { condominium_id: @condominium.id })
    elsif params[:apartment_id].present?
      @apartment = Apartment.find(params[:apartment_id])
      authorize! :read_notices, @apartment

      @notices = @apartment.notices
    end

    @notices = @notices.accessible_by(current_ability).order(created_at: :desc)

    render json: @notices
  end

  # GET /notices/1
  def show
    render json: @notice
  end

  # POST /apartments/:apartment_id/notices
  def create
    current_employee = current_user.employees.find_by(condominium_id: @apartment.condominium_id)
    @notice.creator = current_employee

    if @notice.save
      render json: @notice, status: :created
    else
      render json: @notice.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notices/1
  def update
    if @notice.update(update_notice_params)
      render json: @notice
    else
      render json: @notice.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notices/1
  def destroy
    @notice.destroy
    head :no_content
  end

  private

  def notice_params
    params.require(:notice).permit(:title, :description, :notice_type, :type_info, :status)
  end

  def create_notice_params
    params.require(:notice).permit(:title, :body, :notice_type)
  end

  def update_notice_params
    params.require(:notice).permit(:title, :body, :notice_type, :status)
  end
end
