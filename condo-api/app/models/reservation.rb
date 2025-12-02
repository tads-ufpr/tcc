class Reservation < ApplicationRecord
  belongs_to :facility
  belongs_to :apartment
  belongs_to :creator, class_name: 'User'
end
