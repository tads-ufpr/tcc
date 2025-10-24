# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # ################# #
    # GUEST PERMISSIONS #
    # ################# #
    can :read, Condominium
    can :create, User

    return unless user.present?

    can :create, Condominium

    can :read_notices, Condominium, id: user.employees.pluck(:condominium_id)
    can :read_notices, Apartment, residents: { user_id: user.id }

    can :manage, Condominium, employees: { user_id: user.id, role: "admin" }

    can :read, Apartment, condominium: { id: user.related_condominia_ids }

    can :read, Notice, apartment: { condominium: { id: user.employees.pluck(:condominium_id) } }
    can :read, Notice, apartment: { id: user.apartments.pluck(:id) }
    can [:create, :update, :destroy], Notice, apartment: { condominium: { id: user.employees.pluck(:condominium_id) } }
  end
end
