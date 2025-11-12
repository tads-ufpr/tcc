class Apartment < ApplicationRecord
  belongs_to :condominium

  has_many :residents, dependent: :destroy
  has_many :users, through: :residents
  has_many :notices, dependent: :destroy

  enum :status, {
    pending: 0,
    approved: 1
  }, default: :pending

  validates :number, :floor, presence: true

  scope :approveds, -> { where(status: :approved) }
  scope :pendings, -> { where(status: :pending) }
end
