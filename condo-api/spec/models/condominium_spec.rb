require 'rails_helper'

RSpec.describe Condominium, type: :model do
  describe "associations" do
    it { should have_many(:employees) }
    it { should have_many(:apartments) }
    it { should have_many(:residents).through(:apartments) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:zipcode) }
    it { should validate_presence_of(:neighborhood) }

    it { should validate_uniqueness_of(:name).scoped_to(:city, :address) }
  end
end
