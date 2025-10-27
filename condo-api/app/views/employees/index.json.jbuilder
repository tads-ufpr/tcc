json.array! @employees do |emp|
  json.extract! emp, :id, :description, :role, :user_id, :condominium_id, :created_at, :updated_at
  json.user do
    json.extract! emp.user, :id, :name, :birthdate, :created_at, :updated_at
  end
end
