# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Condominium
    can :create, User

    return unless user.present?

    can :create, Condominium
    can :manage, Condominium, employees: { user_id: user.id, role: 'admin' }

    can :read, Apartment, condominium: { id: user.related_condominia_ids }

    # Allowing the employee to manage any Notice from the Conodminium where he is employeed
    can :manage, Notice, apartment: { condominium_id: user.employees.pluck(:condominium_id) }
    # User can read Notices from any of his apartments
    can :read, Notice, apartment: { id: user.apartments.pluck(:id) }
  end
end
