# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Condominium
    can :create, User

    return unless user.present?

    can :create, Condominium
    can :manage, Condominium, employees: { user_id: user.id, role: "admin" }

    can :read, Apartment, condominium: { id: user.related_condominia_ids }
  end
end
