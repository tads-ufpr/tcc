require 'rails_helper'

RSpec.describe Condominium, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:employees) }
    it { is_expected.to have_many(:apartments) }
    it { is_expected.to have_many(:residents).through(:apartments) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:zipcode) }
    it { is_expected.to validate_presence_of(:neighborhood) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:city, :address) }
  end
end
