class Resident < ApplicationRecord
  belongs_to :user
  belongs_to :apartment


  validates :user_id, uniqueness: { scope: :apartment_id }
end
