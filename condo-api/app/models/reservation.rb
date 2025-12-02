class Reservation < ApplicationRecord
  belongs_to :facility
  belongs_to :apartment
  belongs_to :creator, class_name: 'User'
  validate :creator_must_be_resident_of_apartment, on: :create

  def creator_must_be_resident_of_apartment
    return if apartment.blank? || creator.blank?

    unless apartment.users.include?(creator)
      errors.add(:creator, 'must be a resident of the apartment')
    end
  end
end
