require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'associations' do
    it { should belong_to(:facility) }
    it { should belong_to(:apartment) }
    it { should belong_to(:creator).class_name('User') }
  end

  describe 'validations' do
    let(:apartment) { create(:apartment) }

    describe 'apartment pending reservations limit' do
      let!(:reservation1) { create(:reservation, apartment: apartment, scheduled_date: 1.day.from_now) }
      let!(:reservation2) { create(:reservation, apartment: apartment, scheduled_date: 2.days.from_now) }

      it 'does not allow a third pending reservation for the same apartment' do
        reservation3 = build(:reservation, apartment: apartment, scheduled_date: 3.days.from_now)
        expect(reservation3).not_to be_valid
        expect(reservation3.errors[:apartment]).to include('has reached the limit of pending reservations')
      end

      it 'allows a third reservation if one is in the past' do
        reservation1.update!(scheduled_date: 1.day.ago)
        reservation3 = build(:reservation, apartment: apartment, scheduled_date: 3.days.from_now)
        expect(reservation3).to be_valid
      end
    end

    describe 'scheduled_date' do
      it 'cannot be in the past' do
        reservation = build(:reservation, apartment: apartment, scheduled_date: 1.day.ago)
        expect(reservation).not_to be_valid
        expect(reservation.errors[:scheduled_date]).to include("can't be in the past")
      end

      it 'cannot be more than 2 months in the future' do
        reservation = build(:reservation, apartment: apartment, scheduled_date: 2.months.from_now + 1.day)
        expect(reservation).not_to be_valid
        expect(reservation.errors[:scheduled_date]).to include("can't be more than 2 months in the future")
      end

      it 'can be today' do
        reservation = build(:reservation, apartment: apartment, scheduled_date: Date.today)
        expect(reservation).to be_valid
      end

      it 'can be 2 months in the future' do
        reservation = build(:reservation, apartment: apartment, scheduled_date: 2.months.from_now)
        expect(reservation).to be_valid
      end
    end
  end
end
