json.extract! @condominium, :id, :name, :zipcode, :city, :state, :address, :neighborhood, :number

authorized_apartments = @condominium.apartments.accessible_by(current_ability)

json.apartments authorized_apartments do |apartment|
  json.partial! "apartments/apartment", apartment: apartment
end
