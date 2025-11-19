# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # ################# #
    # GUEST PERMISSIONS #
    # ################# #
    guest_permissions

    return unless user.present?

    # ##################### #
    # AUTHENTICATED PERMISSIONS #
    # ##################### #
    authenticated_permissions(user)

    # ############### #
    # CONDOMINIUM     #
    # ############### #
    condominium_permissions(user)

    # ############ #
    # APARTMENT    #
    # ############ #
    apartment_permissions(user)

    # ###### #
    # NOTICE #
    # ###### #
    notice_permissions(user)

    # ######## #
    # EMPLOYEE #
    # ######## #
    employee_permissions(user)

    # ######## #
    # RESIDENT #
    # ######## #
    resident_permissions(user)
  end

  private

  def guest_permissions
    can :read, Condominium
    can :create, User
  end

  def authenticated_permissions(user)
    can :show, User, id: user.id
    can :create, Condominium
    can :create, Apartment
  end

  def condominium_permissions(user)
    # Admin can fully manage their condominiums
    can :manage, Condominium, employees: { user_id: user.id, role: :admin }

    # Read notices in their condominiums (as employee)
    can :read_notices, Condominium, id: user.employees.pluck(:condominium_id)

    # Any resident or employee can see employee list
    can :read_employees, Condominium, id: user.related_condominia_ids
  end

  def apartment_permissions(user)
    admin_condos = user.employees.where(role: :admin).pluck(:condominium_id)
    owner_apartments = { residents: { user_id: user.id, owner: true } }
    admin_condos_scope = { id: admin_condos }

    # Read apartments
    can :read, Apartment, condominium: { id: user.related_condominia_ids }

    # Update and destroy
    can [:update, :destroy], Apartment, owner_apartments
    can [:update, :destroy], Apartment, condominium: admin_condos_scope

    # Approve (admin only)
    can :approve, Apartment, condominium: admin_condos_scope

    # Read notices in their apartments
    can :read_notices, Apartment, residents: { user_id: user.id }
    can :read_notices, Apartment, condominium_id: admin_condos
  end

  def notice_permissions(user)
    employeed_condos = user.employees.pluck(:condominium_id)
    own_apartments = user.apartments.pluck(:id)

    # Read notices
    can :read, Notice, apartment: { condominium: { id: employeed_condos } }
    can :read, Notice, apartment: { id: own_apartments }

    # Create, update, destroy notices (employees only)
    can [:create, :update, :destroy], Notice, apartment: { condominium: { id: employeed_condos } }
  end

  def employee_permissions(user)
    admin_condos = user.employees.admins.pluck(:condominium_id)

    # CRUD operations (admin only)
    can [:create, :read, :update], Employee, condominium: { id: admin_condos }

    # Destroy with custom logic: admin only, cannot delete self
    can :destroy, Employee do |employee_to_destroy|
      is_admin_in_condo = admin_condos.include?(employee_to_destroy.condominium_id)
      is_not_self = employee_to_destroy.user_id != user.id
      is_admin_in_condo && is_not_self
    end
  end

  def resident_permissions(user)
    # Manage residents (owners and apartment admins)
    can :manage, Resident, apartment: { residents: { user_id: user.id, owner: true } }
    can :manage, Resident, apartment: { condominium: { id: user.employees.where(role: :admin).pluck(:condominium_id) } }

    # Allow any resident to destroy themselves
    can :destroy, Resident, user_id: user.id
  end
end
