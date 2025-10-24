5.times do |i|
  User.create({
    email: "a#{i}@a.com",
    password: 'pokpok',
    first_name: "User A#{i}",
    last_name: 'Tester',
    birthdate: Faker::Date.between(from: '1940-01-01', to: '2000-01-01'),
    document: Faker::IdNumber.brazilian_citizen_number
  })
end

5.times do |i|
  Condominium.create({
    name: "Condo #{i}",
    zipcode: Faker::Address.zip,
    address: Faker::Address.street_name,
    neighborhood: Faker::Address.community,
    city: 'Curitiba',
    state: 'PR',
    number: "#{i}"
  })
end

10.times do |i|
  Apartment.create({
    condominium_id: Condominium.first.id,
    floor: i+1,
    number: "#{i}0#{i%3}",
    tower: "A"
  })
end

# FIRST CONDOMINIUM CONFIGS
Employee.create({
  user_id: User.first.id,
  condominium_id: Condominium.first.id,
  role: "admin",
  description: "Síndico"
})

Resident.create({
  user_id: User.first.id,
  apartment_id: Apartment.first.id
})

Resident.create({
  user_id: User.second.id,
  apartment_id: Apartment.second.id
})
