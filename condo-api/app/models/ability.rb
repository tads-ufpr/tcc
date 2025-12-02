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

    # ################## #
    # ROLE-BASED PERMISSIONS #
    # ################## #
    apply_employee_permissions(user)
    apply_resident_permissions(user)
  end

  private

  # ============ GUEST & AUTHENTICATED ============

  def guest_permissions
    can :read, Condominium
    can :create, User
  end

  def authenticated_permissions(user)
    can :show, User, id: user.id
    can :create, Condominium
    can :create, Apartment
  end

  # ============ EMPLOYEE ROLES ============

  def apply_employee_permissions(user)
    return unless user.employees.any?

    admin_condo_ids = user.employees.where(role: :admin).pluck(:condominium_id)
    collaborator_condo_ids = user.employees.where(role: :collaborator).pluck(:condominium_id)

    admin_permissions(user, admin_condo_ids) if admin_condo_ids.any?
    collaborator_permissions(user, collaborator_condo_ids) if collaborator_condo_ids.any?
    employee_common_permissions(user)
  end

  def admin_permissions(user, admin_condo_ids)
    admin_condominium_rules(user, admin_condo_ids)
    admin_apartment_rules(user, admin_condo_ids)
    admin_notice_rules(user, admin_condo_ids)
    admin_employee_rules(user, admin_condo_ids)
    admin_resident_rules(user, admin_condo_ids)
    admin_facility_rules(user, admin_condo_ids)
    admin_reservation_rules(user, admin_condo_ids)
  end

  def admin_condominium_rules(user, admin_condo_ids)
    can :manage, Condominium, id: admin_condo_ids
  end

  def admin_apartment_rules(user, admin_condo_ids)
    can [:read, :update, :destroy, :approve], Apartment, condominium_id: admin_condo_ids
  end

  def admin_notice_rules(user, admin_condo_ids)
    can [:create, :read, :update, :destroy], Notice, apartment: { condominium_id: admin_condo_ids }
  end

  def admin_employee_rules(user, admin_condo_ids)
    # CRUD operations (admin only)
    can [:create, :read, :update], Employee, condominium_id: admin_condo_ids

    # Destroy with custom logic: admin only, cannot delete self
    can :destroy, Employee do |employee_to_destroy|
      admin_condo_ids.include?(employee_to_destroy.condominium_id) &&
        employee_to_destroy.user_id != user.id
    end
  end

  def admin_resident_rules(user, admin_condo_ids)
    can :manage, Resident, apartment: { condominium_id: admin_condo_ids }
  end

  def admin_facility_rules(_user, admin_condo_ids)
    can :manage, Facility, condominium_id: admin_condo_ids
  end

  def admin_reservation_rules(_user, admin_condo_ids)
    can :manage, Reservation, facility: { condominium_id: admin_condo_ids }
  end

  def collaborator_permissions(user, collaborator_condo_ids)
    collaborator_apartment_rules(user, collaborator_condo_ids)
    collaborator_notice_rules(user, collaborator_condo_ids)
    collaborator_facility_rules(user, collaborator_condo_ids)
    collaborator_reservation_rules(user, collaborator_condo_ids)
  end

  def collaborator_apartment_rules(user, collaborator_condo_ids)
    can :read, Apartment, condominium_id: collaborator_condo_ids
  end

  def collaborator_notice_rules(user, collaborator_condo_ids)
    can [:create, :read, :update, :destroy], Notice, apartment: { condominium_id: collaborator_condo_ids }
  end

  def collaborator_facility_rules(_user, collaborator_condo_ids)
    can :read, Facility, condominium_id: collaborator_condo_ids
  end

  def collaborator_reservation_rules(_user, collaborator_condo_ids)
    can :read, Reservation, facility: { condominium_id: collaborator_condo_ids }
  end

  def employee_common_permissions(user)
    employee_condo_ids = user.employees.pluck(:condominium_id)

    employee_condominium_rules(user, employee_condo_ids)
    employee_read_rules(user, employee_condo_ids)
    employee_resident_rules(user, employee_condo_ids)
  end

  def employee_condominium_rules(user, employee_condo_ids)
    can :read_notices, Condominium, id: employee_condo_ids
    can :read_employees, Condominium, id: employee_condo_ids
  end

  def employee_read_rules(user, employee_condo_ids)
    can :read_notices, Apartment, condominium_id: employee_condo_ids
  end

  def employee_resident_rules(user, employee_condo_ids)
    can :read, Resident, apartment: { condominium_id: employee_condo_ids }
  end

  def employee_resident_rules(user, employee_condo_ids)
    can :read, Resident, apartment: { condominium_id: employee_condo_ids }
  end

  # ============ RESIDENT ROLES ============

  def apply_resident_permissions(user)
    return unless user.residents.any?

    owner_apartment_ids = user.apartments.joins(:residents)
                              .where(residents: { user_id: user.id, owner: true })
                              .pluck(:id)

    non_owner_apartment_ids = user.apartments.joins(:residents)
                                  .where(residents: { user_id: user.id, owner: false })
                                  .pluck(:id)

    owner_permissions(user, owner_apartment_ids) if owner_apartment_ids.any?
    resident_permissions(user, non_owner_apartment_ids) if non_owner_apartment_ids.any?
    resident_common_permissions(user)
  end

  def owner_permissions(user, owner_apartment_ids)
    owner_apartment_rules(user, owner_apartment_ids)
    owner_resident_rules(user, owner_apartment_ids)
    owner_notice_rules(user, owner_apartment_ids)
  end

  def owner_apartment_rules(user, owner_apartment_ids)
    can [:update, :destroy], Apartment, id: owner_apartment_ids
  end

  def owner_resident_rules(user, owner_apartment_ids)
    can :manage, Resident, apartment_id: owner_apartment_ids
  end

  def owner_notice_rules(user, owner_apartment_ids)
    can :read, Notice, apartment_id: owner_apartment_ids
  end

  def resident_permissions(user, non_owner_apartment_ids)
    resident_notice_rules(user, non_owner_apartment_ids)
  end

  def resident_notice_rules(user, non_owner_apartment_ids)
    # Residents can ONLY read notices, nothing else
    can :read, Notice, apartment_id: non_owner_apartment_ids
  end

  def resident_common_permissions(user)
    resident_condo_ids = user.apartments.pluck(:condominium_id).uniq
    resident_apartment_ids = user.apartments.pluck(:id)

    resident_apartment_read_rules(user, resident_apartment_ids)
    resident_condominium_rules(user, resident_condo_ids)
    resident_notice_read_rules(user, resident_condo_ids, resident_apartment_ids)
    resident_self_rules(user)
    resident_resident_rules(user, resident_condo_ids)
    resident_facility_rules(user, resident_condo_ids)
    resident_reservation_rules(user, resident_condo_ids)
  end

  def resident_apartment_read_rules(user, resident_apartment_ids)
    can :read, Apartment, id: resident_apartment_ids
  end

  def resident_condominium_rules(user, resident_condo_ids)
    can :read_employees, Condominium, id: resident_condo_ids
  end

  def resident_notice_read_rules(user, resident_condo_ids, resident_apartment_ids)
    can :read_notices, Apartment, id: resident_apartment_ids
  end

  def resident_self_rules(user)
    can :destroy, Resident, user_id: user.id
  end

  def resident_resident_rules(user, resident_condo_ids)
    can :read, Resident, apartment: { condominium_id: resident_condo_ids }
  end

  def resident_facility_rules(_user, resident_condo_ids)
    can :read, Facility, condominium_id: resident_condo_ids
  end

  def resident_reservation_rules(user, resident_condo_ids)
    can :create, Reservation, facility: { condominium_id: resident_condo_ids }, apartment_id: user.apartment_ids
    can :read, Reservation, facility: { condominium_id: resident_condo_ids }
    can :destroy, Reservation, creator_id: user.id, facility: { condominium_id: resident_condo_ids }
  end
end
