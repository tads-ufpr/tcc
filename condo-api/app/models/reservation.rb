class Reservation < ApplicationRecord
  belongs_to :facility
  belongs_to :apartment
  belongs_to :creator, class_name: 'User'

  validates :apartment, presence: true
  validates :scheduled_date, presence: true, uniqueness: { scope: :facility_id }
  validate :creator_must_be_resident_of_apartment, on: :create

  validate :scheduled_date_is_valid, on: :create
  validate :apartment_pending_reservations_limit, on: :create
  validate :apartment_must_be_approved, on: :create

  before_destroy :prevent_destruction_of_past_reservation

  private

  def scheduled_date_is_valid
    return if scheduled_date.blank?

    if scheduled_date < Date.current
      errors.add(:scheduled_date, "can't be in the past")
    end

    if scheduled_date > Date.current + 2.months
      errors.add(:scheduled_date, "can't be more than 2 months in the future")
    end
  end

  def apartment_pending_reservations_limit
    return if apartment.blank?

    if apartment.reservations.where('scheduled_date >= ?', Date.current).count >= 2
      errors.add(:apartment, 'has reached the limit of pending reservations')
    end
  end

  def creator_must_be_resident_of_apartment
    return if apartment.blank? || creator.blank?

    unless apartment.users.include?(creator)
      errors.add(:creator, 'must be a resident of the apartment')
    end
  end

  def prevent_destruction_of_past_reservation
    return unless scheduled_date < Date.current

    errors.add(:base, "Cannot delete a reservation in the past")
    throw :abort
  end

  def apartment_must_be_approved
    return if apartment.blank?

    errors.add(:apartment, "can't have a pending status") if apartment.pending?
  end
end
