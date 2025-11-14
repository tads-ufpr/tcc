require 'rails_helper'

RSpec.describe Apartment, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:residents) }
    it { is_expected.to have_many(:users).through(:residents) }
    it { is_expected.to belong_to(:condominium) }
    it { is_expected.to have_many(:notices) }
  end

  describe "validations" do
    let(:condo) { create(:condominium) }
    let(:condo_2) { create(:condominium) }

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:floor) }

    context "when status is pending" do
      let!(:dup_apartment) { build(:apartment, condominium: condo, floor: 1, number: "101", tower: "A", status: :pending) }

      before do
        create(:apartment, condominium: condo, floor: 1, number: "101", tower: "A", status: :pending)
      end

      it "allows duplicate apartments" do
        expect(dup_apartment).to be_valid
      end
    end

    context "when status is approved" do
      let!(:dup_apartment) { build(:apartment, condominium: condo, floor: 1, number: "101", tower: "A", status: :approved) }
      let!(:same_ap_another_condo) { build(:apartment, condominium: condo_2, floor: 1, number: "101", tower: "A", status: :approved) }

      before do
        create(:apartment, condominium: condo, floor: 1, number: "101", tower: "A", status: :approved)
      end

      it "does not allow duplicate apartments" do
        expect(dup_apartment).not_to be_valid
        expect(dup_apartment.errors[:number]).to include("has already been taken")
      end

      it "allows 'duplicated' apartemtns for distinct condominium" do
        expect(same_ap_another_condo).to be_valid
      end
    end
  end
end
