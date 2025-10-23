class Apartment < ApplicationRecord
  belongs_to :condominium

  has_many :residents, dependent: :destroy
  has_many :users, through: :residents
  has_many :notices, dependent: :destroy

  validates :number, presence: true
end
