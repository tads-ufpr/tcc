require 'rails_helper'

RSpec.describe Apartment, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:residents) }
    it { is_expected.to have_many(:users).through(:residents) }
    it { is_expected.to belong_to(:condominium) }
    it { is_expected.to have_many(:notices) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:number) }
  end
end
