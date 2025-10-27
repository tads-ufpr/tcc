json.extract! @employee, :description, :condominium_id, :role
json.user do
  json.partial! "users/user", user: @employee.user
end
