class Notice < ApplicationRecord
  belongs_to :apartment
  belongs_to :creator, class_name: "User"
end
