class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :employees
  has_many :condominium_as_employee, through: :employees, source: :condominium

  has_many :residents
  has_many :apartments, through: :residents
  has_many :condominium_as_resident, through: :apartments, source: :condominium
  has_many :reservations, foreign_key: :creator_id, dependent: :destroy

  alias_attribute :cpf, :document

  validates :document, presence: true
  validates :first_name, presence: true

  def name
    [first_name, last_name].compact.join(" ")
  end

  def name=(full_name)
    sanitize_name = full_name.to_s.strip

    parts = sanitize_name.split(" ", 2)

    self.first_name = parts[0]
    self.last_name = parts[1]
  end

  def related_condominia
    employee_condos = condominium_as_employee.to_a
    resident_condos = condominium_as_resident.to_a

    (employee_condos + resident_condos).uniq
  end

  def related_condominia_ids
    self.related_condominia.map { |condo| condo.id }
  end
end
