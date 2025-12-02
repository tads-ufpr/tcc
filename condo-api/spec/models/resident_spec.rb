require 'rails_helper'

RSpec.describe Resident, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:apartment) }
  end

  describe 'validations' do
    subject { create(:resident) }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:apartment_id) }

    describe '#first_resident?' do
      let(:apartment) { create(:apartment) }

      context 'when it is the first resident' do
        let(:resident) { create(:resident, apartment: apartment) }

        it 'sets the resident as owner' do
          expect(resident.owner).to be(true)
        end
      end

      context 'when it is not the first resident' do
        before { create(:resident, apartment: apartment, owner: true) }

        let(:new_resident) { create(:resident, apartment: apartment) }

        it 'does not set the new resident as owner' do
          expect(new_resident.owner).to be(false)
        end
      end
    end
  end
end
