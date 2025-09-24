class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :employees
  has_many :condominia, through: :employees

  alias_attribute :cpf, :document

  def name
    [first_name, last_name].compact.join(" ")
  end

  def name=(full_name)
    sanitize_name = full_name.to_s.strip

    parts = sanitize_name.split(" ", 2)

    self.first_name = parts[0]
    self.last_name = parts[1]
  end
end
