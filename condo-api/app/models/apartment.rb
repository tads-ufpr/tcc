class Apartment < ApplicationRecord
  belongs_to :condominium

  has_many :residents, dependent: :destroy
  has_many :users, through: :residents

  validates :number, presence: true
end
