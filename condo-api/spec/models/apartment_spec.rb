require 'rails_helper'

RSpec.describe Apartment, type: :model do
  describe "associations" do
    it { should have_many(:residents) }
    it { should have_many(:users).through(:residents) }
    it { should belong_to(:condominium) }
  end

  describe "validations" do
    it { should validate_presence_of(:number) }
  end
end
