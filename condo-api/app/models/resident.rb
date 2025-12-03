class Resident < ApplicationRecord
  belongs_to :user
  belongs_to :apartment

  validates :user_id, uniqueness: { scope: :apartment_id }
  validate :first_resident?, on: :create

  private
  def first_resident?
    return if apartment.blank?
    self.owner = self.apartment.residents.where(owner: true).count == 0
  end
end
