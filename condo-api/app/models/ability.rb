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

    # Any user can create a new Condominium, this will create an Employee(:admin)
    # So only Employees(:admins) can manage the Condominium
    can :create, Condominium
    can :manage, Condominium, employees: { user_id: user.id, role: "admin" }

    can :read_notices, Condominium, id: user.employees.pluck(:condominium_id)
    can :read_notices, Apartment, residents: { user_id: user.id }
    can :read_notices, Apartment, condominium_id: user.employees.pluck(:condominium_id)
    can :create, Apartment

    can :read, Apartment, condominium: { id: user.related_condominia_ids }
    can :read, Apartment, condominium: { id: user.employees.pluck(:condominium_id) }
    can :approve, Apartment, condominium: { id: user.employees.where(role: [:admin, :manager]).pluck(:condominium_id) }

    can [:update, :destroy], Apartment, residents: { user_id: user.id, owner: true }
    can [:update, :destroy], Apartment, condominium: { id: user.employees.where(role: :admin).pluck(:condominium_id) }

    # Only residents and employees are allowed to read a notice
    # Employee can read any notice
    # Residente can only read it's Apartment notices
    can :read, Notice, apartment: { condominium: { id: user.employees.pluck(:condominium_id) } }
    can :read, Notice, apartment: { id: user.apartments.pluck(:id) }

    # :admins only can interact with Employee
    can [:create, :read, :update], Employee, condominium: { id: user.employees.admins.pluck(:condominium_id) }
    # User can only delete an Employee if himself is :admin
    # and if he is not trying to delete himself
    can :destroy, Employee do |employee_to_destroy|
      related_condo_emp = user.employees.admins.pluck(:condominium_id).include?(employee_to_destroy.condominium_id)

      is_not_self = (employee_to_destroy.user_id != user.id)

      related_condo_emp && is_not_self
    end
    # Any resident or employee can request for employee's #index
    can :read_employees, Condominium, id: user.related_condominia_ids

    # TO DO - remove the ability to destroy a Notice. It should be closed instead
    can [:create, :update, :destroy], Notice, apartment: { condominium: { id: user.employees.pluck(:condominium_id) } }

    can :manage, Resident, apartment: { residents: { user_id: user.id, owner: true } }
    can :manage, Resident, apartment: { condominium: { id: user.employees.where(role: [:admin, :manager]).pluck(:condominium_id) } }
    can :destroy, Resident, user_id: user.id # Allow a resident to destroy themselves
  end
end
