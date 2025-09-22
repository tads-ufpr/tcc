# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Condominium

    return unless user.present?

    can :create, Condominium
    can :manage, Condominium, employees: { user_id: user.id, role: "admin" }
  end
end
