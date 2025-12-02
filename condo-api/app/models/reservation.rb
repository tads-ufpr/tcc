class Reservation < ApplicationRecord
  belongs_to :facility
  belongs_to :apartment
  belongs_to :creator, class_name: 'User'

  validates :apartment, presence: true
  validate :creator_must_be_resident_of_apartment, on: :create

  validate :scheduled_date_is_valid, on: :create
  validate :apartment_pending_reservations_limit, on: :create

  private

  def scheduled_date_is_valid
    return if scheduled_date.blank?

    if scheduled_date < Date.today
      errors.add(:scheduled_date, "can't be in the past")
    end

    if scheduled_date > Date.today + 2.months
      errors.add(:scheduled_date, "can't be more than 2 months in the future")
    end
  end

  def apartment_pending_reservations_limit
    return if apartment.blank?

    if apartment.reservations.where('scheduled_date >= ?', Date.today).count >= 2
      errors.add(:apartment, 'has reached the limit of pending reservations')
    end
  end

  def creator_must_be_resident_of_apartment
    return if apartment.blank? || creator.blank?

    unless apartment.users.include?(creator)
      errors.add(:creator, 'must be a resident of the apartment')
    end
  end
end
