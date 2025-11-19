class Employee < ApplicationRecord
  DEFAULT = "CONDOMINIUM CREATOR".freeze

  enum :role, {
    admin: "admin",
    collaborator: "collaborator"
  }, default: :collaborator

  belongs_to :user
  belongs_to :condominium

  has_many :created_notices, class_name: "Notice", foreign_key: "creator_id",
           dependent: :nullify, inverse_of: :creator
  validates :user_id, uniqueness: { scope: :condominium_id }
  validates :description, :condominium_id, :user_id, :role, presence: true

  scope :admins, -> { where(role: :admin) }

  def admin?
    self.role == :admin
  end
end
