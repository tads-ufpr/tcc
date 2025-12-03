require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:facility) }
    it { is_expected.to belong_to(:apartment) }
    it { is_expected.to belong_to(:creator).class_name('User') }
  end

  describe 'validations' do
    let(:apartment) { create(:apartment, :with_residents) }
    let(:creator) { apartment.residents.first.user }

    describe 'apartment must be approved' do
      context 'when apartment is pending' do
        before { apartment.update!(status: :pending) }

        it 'is not valid' do
          reservation = build(:reservation, apartment: apartment, creator: creator)
          expect(reservation).not_to be_valid
        end

        it 'adds an error message' do
          reservation = build(:reservation, apartment: apartment, creator: creator)
          reservation.valid?
          expect(reservation.errors[:apartment]).to include("can't have a pending status")
        end
      end

      context 'when apartment is approved' do
        before { apartment.update!(status: :approved) }

        it 'is valid' do
          facility = create(:facility, schedulable: true)
          reservation = build(:reservation, facility: facility, apartment: apartment, creator: creator)
          expect(reservation).to be_valid
        end
      end
    end

    describe 'apartment pending reservations limit' do
      before { apartment.update!(status: :approved) }

      let(:schedulable_facility) { create(:facility, schedulable: true) }
      let!(:first_pending_reservation) { create(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 1.day.from_now) }
      let!(:second_pending_reservation) { create(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 2.days.from_now) }

      it 'does not allow a third pending reservation for the same apartment' do
        reservation3 = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 3.days.from_now)
        expect(reservation3).not_to be_valid
        expect(reservation3.errors[:apartment]).to include('has reached the limit of pending reservations')
      end

      it 'allows a third reservation if one is in the past' do
        first_pending_reservation.update!(scheduled_date: 1.day.ago)
        reservation3 = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 3.days.from_now)
        expect(reservation3).to be_valid
      end
    end

    describe 'scheduled_date' do
      before { apartment.update!(status: :approved) }

      let(:schedulable_facility) { create(:facility, schedulable: true) }

      it 'cannot be in the past' do
        reservation = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 1.day.ago)
        expect(reservation).not_to be_valid
        expect(reservation.errors[:scheduled_date]).to include("can't be in the past")
      end

      it 'cannot be more than 2 months in the future' do
        reservation = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 2.months.from_now + 1.day)
        expect(reservation).not_to be_valid
        expect(reservation.errors[:scheduled_date]).to include("can't be more than 2 months in the future")
      end

      it 'can be today' do
        reservation = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: Date.current)
        expect(reservation).to be_valid
      end

      it 'can be 2 months in the future' do
        reservation = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: 2.months.from_now)
        expect(reservation).to be_valid
      end

      it 'cannot be nil' do
        reservation = build(:reservation, facility: schedulable_facility, apartment: apartment, creator: creator, scheduled_date: nil)
        expect(reservation).not_to be_valid
        expect(reservation.errors[:scheduled_date]).to include("can't be blank")
      end
    end

        describe 'uniqueness of scheduled_date scoped to facility_id' do

          let(:facility) { create(:facility, schedulable: true) }

          let(:apartment) { create(:apartment, :approved, :with_residents) } # Ensure apartment is approved and has residents

          let(:creator) { apartment.residents.first.user } # Use a resident of the apartment as creator

    

          let!(:existing_reservation) { create(:reservation, facility: facility, apartment: apartment, creator: creator, scheduled_date: Date.current) }

    

          it 'does not allow a reservation for the same facility on the same date' do

            duplicate_reservation = build(:reservation, facility: facility, apartment: apartment, creator: creator, scheduled_date: Date.current)

            expect(duplicate_reservation).not_to be_valid

            expect(duplicate_reservation.errors[:scheduled_date]).to include("has already been taken")

          end

    

          it 'allows a reservation for a different facility on the same date' do

            another_facility = create(:facility, schedulable: true)

            valid_reservation = build(:reservation, facility: another_facility, apartment: apartment, creator: creator, scheduled_date: Date.current)

            expect(valid_reservation).to be_valid

          end

    

          it 'allows a reservation for the same facility on a different date' do

            valid_reservation = build(:reservation, facility: facility, apartment: apartment, creator: creator, scheduled_date: Date.current + 1.day)

            expect(valid_reservation).to be_valid

          end
        end

    describe 'facility must be schedulable' do
      let(:apartment) { create(:apartment, :approved, :with_residents) }
      let(:creator) { apartment.residents.first.user }

      context 'when facility is not schedulable' do
        let(:facility) { create(:facility, schedulable: false) }

        it 'is not valid' do
          reservation = build(:reservation, facility: facility, apartment: apartment, creator: creator)
          expect(reservation).not_to be_valid
        end

        it 'adds an error message' do
          reservation = build(:reservation, facility: facility, apartment: apartment, creator: creator)
          reservation.valid?
          expect(reservation.errors[:facility]).to include('is not schedulable')
        end
      end

      context 'when facility is schedulable' do
        let(:facility) { create(:facility, schedulable: true) }

        it 'is valid' do
          reservation = build(:reservation, facility: facility, apartment: apartment, creator: creator)
          expect(reservation).to be_valid
        end
      end
    end
  end
end
