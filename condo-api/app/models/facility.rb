class Facility < ApplicationRecord
  belongs_to :condominium

  validates :name, :description, :tax, presence: true
  validates :tax, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
