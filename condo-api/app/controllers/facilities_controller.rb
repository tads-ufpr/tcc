class FacilitiesController < ApplicationController
  before_action :set_facility, only: %i[ show update destroy ]

  # GET /facilities
  # GET /facilities.json
  def index
    @facilities = Facility.all
  end

  # GET /facilities/1
  # GET /facilities/1.json
  def show
  end

  # POST /facilities
  # POST /facilities.json
  def create
    @facility = Facility.new(facility_params)

    if @facility.save
      render :show, status: :created, location: @facility
    else
      render json: @facility.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /facilities/1
  # PATCH/PUT /facilities/1.json
  def update
    if @facility.update(facility_params)
      render :show, status: :ok, location: @facility
    else
      render json: @facility.errors, status: :unprocessable_entity
    end
  end

  # DELETE /facilities/1
  # DELETE /facilities/1.json
  def destroy
    @facility.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facility
      @facility = Facility.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def facility_params
      params.expect(facility: [ :name, :description, :tax, :condominium_id ])
    end
end
