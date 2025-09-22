class Condominium < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :users, through: :employees

  validates :city, :state, :address, presence: true
  validates :neighborhood, :zipcode, :number, presence: true
  validates :name, presence: true, uniqueness: { scope: :city }
end
