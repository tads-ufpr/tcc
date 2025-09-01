class Condominium < ApplicationRecord
  validates :city, :state, :address, presence: true
  validates :neighborhood, :zipcode, :number, presence: true

  validates :name, presence: true, uniqueness: { scope: :city }
end
