class Facility < ApplicationRecord
  belongs_to :condominium

  validates :name, presence: true
  validates :tax, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
