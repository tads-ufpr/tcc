User.create({
  email: 'a@a.com',
  password: 'pokpok',
  first_name: 'User',
  last_name: 'A',
  birthdate: '15/07/1992',
  document: '08727227910'
})

Condominium.create({
  name: "First Condo",
  zipcode: "80040-110",
  address: "Rua Almirante Tamandaré",
  neighborhood: "Juvevê",
  city: "Curitiba",
  state: "PR",
  number: "1466"
})

Employee.create({
  user_id: User.first.id,
  condominium_id: Condominium.first.id,
  role: "admin",
  description: "Síndico"
})

Apartment.create({
  condominium_id: Condominium.first.id,
  floor: 7,
  number: "704",
  tower: "A"
})

Resident.create({
  user_id: User.first.id,
  apartment_id: Apartment.first.id
})
