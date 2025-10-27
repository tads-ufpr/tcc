json.extract! @condominium, :id, :name, :zipcode, :city, :state, :address, :neighborhood, :number

authorized_apartments = @condominium.apartments

json.apartments authorized_apartments do |apartment|
  json.partial! "apartments/apartment", apartment: apartment
end
