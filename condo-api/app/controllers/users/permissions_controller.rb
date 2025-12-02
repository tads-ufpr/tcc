# TO DO - REMOVER THIS CONTROLLER

class Users::PermissionsController < ApplicationController
  load_and_authorize_resource class: "User"

  def show
    @user = current_user
    condominiums = user_condominiums

    permissions = condominiums.map do |condominium|
      set_permissions(condominium)
    end.compact

    render json: permissions
  end

  private

  def user_condominiums
    current_user.related_condominia.uniq
  end

  def set_permissions(condominium)
    employee_role = get_employee_role(condominium)
    resident_role = get_resident_role(condominium)

    role = highest_role(employee_role, resident_role)

    return unless role

    {
      condominium_id: condominium.id,
      role: role,
      permissions: permissions_for_role(role)
    }
  end

  def get_employee_role(condominium)
    employee = @user.employees.find_by(condominium_id: condominium.id)
    employee&.role
  end

  def get_resident_role(condominium)
    resident = @user.residents.joins(:apartment).find_by(apartments: { condominium_id: condominium.id })
    return unless resident

    resident.owner? ? "owner" : "resident"
  end

  def highest_role(employee_role, resident_role)
    roles = [employee_role, resident_role].compact
    return nil if roles.empty?

    role_priority = %w[admin collaborator owner resident]
    roles.min_by { |role| role_priority.index(role) }
  end

  def permissions_for_role(role)
    case role
    when "admin"
      admin_permissions
    when "collaborator"
      collaborator_permissions
    when "owner"
      owner_permissions
    when "resident"
      residents_permissions
    else
      []
    end
  end

  def admin_permissions
    %w[
      readCondominium
      showUser
      createCondominium
      createApartment
      manageCondominium
      readNotices
      readEmployees
      readApartment
      updateApartment
      destroyApartment
      approveApartment
      createEmployee
      readEmployee
      updateEmployee
      destroyEmployee
      createNotice
      readNotice
      updateNotice
      destroyNotice
      createResident
      readResident
      updateResident
      destroyResident
      createReservation
      readReservation
      destroyReservation
    ]
  end

  def collaborator_permissions
    %w[
      readCondominium
      showUser
      createCondominium
      createApartment
      readApartment
      readNotices
      readEmployees
      createNotice
      readNotice
      updateNotice
      destroyNotice
      readReservation
    ]
  end

  def owner_permissions
    %w[
      readCondominium
      showUser
      createCondominium
      createApartment
      readEmployees
      readApartment
      updateApartment
      destroyApartment
      createResident
      readResident
      updateResident
      destroyResident
      readNotice
      destroyResident
      createReservation
      readReservation
      destroyReservation
    ]
  end

  def residents_permissions
    %w[
      readCondominium
      showUser
      createCondominium
      createApartment
      readEmployees
      readApartment
      readNotice
      destroyResident
      createReservation
      readReservation
      destroyReservation
    ]
  end
end
