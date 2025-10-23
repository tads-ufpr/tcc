class Employee < ApplicationRecord
  ROLES = %w[admin manager normal].freeze
  DEFAULT = "CONDOMINIUM CREATOR".freeze

  belongs_to :user
  belongs_to :condominium

  has_many :created_notices, class_name: "Notice", foreign_key: "creator_id",
           dependent: :nullify, inverse_of: :creator

  validates :description, :condominium, :user, presence: true
  validates :user_id, uniqueness: { scope: :condominium_id }
  validates :role, presence: true, inclusion: { in: ROLES }

  scope :admins, -> { where(role: "admin") }
  scope :managers, -> { where(role: "manager") }

  def admin?
    self.role == "admin"
  end
end
