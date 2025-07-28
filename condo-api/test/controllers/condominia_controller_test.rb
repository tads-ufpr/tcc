require "test_helper"

class CondominiaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @condominium = condominia(:one)
  end

  test "should get index" do
    get condominia_url, as: :json
    assert_response :success
  end

  test "should create condominium" do
    assert_difference("Condominium.count") do
      post condominia_url, params: { condominium: { address: @condominium.address, city: @condominium.city, district: @condominium.district, name: @condominium.name, number: @condominium.number, state: @condominium.state, zip_code: @condominium.zip_code } }, as: :json
    end

    assert_response :created
  end

  test "should show condominium" do
    get condominium_url(@condominium), as: :json
    assert_response :success
  end

  test "should update condominium" do
    patch condominium_url(@condominium), params: { condominium: { address: @condominium.address, city: @condominium.city, district: @condominium.district, name: @condominium.name, number: @condominium.number, state: @condominium.state, zip_code: @condominium.zip_code } }, as: :json
    assert_response :success
  end

  test "should destroy condominium" do
    assert_difference("Condominium.count", -1) do
      delete condominium_url(@condominium), as: :json
    end

    assert_response :no_content
  end
end
