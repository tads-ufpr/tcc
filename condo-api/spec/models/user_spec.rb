require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:residents) }
    it { should have_many(:apartments).through(:residents) }
    it { should have_many(:condominium_as_resident).through(:apartments) }
    it { should have_many(:condominium_as_employee).through(:employees) }
  end

  describe "aliases" do
    it ":cpf is :document" do
      cpf = Faker::IdNumber.brazilian_citizen_number
      user = User.build(document: cpf)

      expect(user.cpf).to eq(user.document)
    end
    it ":name is :first_name with :last_name" do
      user = User.build(name: "Testing Tester")

      expect(user.first_name).to eq("Testing")
      expect(user.last_name).to eq("Tester")
    end
  end

  describe '#related_condominia' do
    let(:user) { create(:user) }

    it 'returns an empty array when user has no relationship' do
      expect(user.related_condominia).to be_empty
    end

    it 'returns condominiums where the user is a resident' do
      condominium = create(:condominium)
      apartment = create(:apartment, condominium: condominium)
      create(:resident, user: user, apartment: apartment)

      expect(user.related_condominia).to contain_exactly(condominium)
    end

    it 'returns condominiums where the user is an employee' do
      condominium = create(:condominium)
      create(:employee, user: user, condominium: condominium)

      expect(user.related_condominia).to contain_exactly(condominium)
    end

    it 'returns unique condominiums when user is a resident and employee of the same one' do
      condominium = create(:condominium)
      apartment = create(:apartment, condominium: condominium)
      create(:resident, user: user, apartment: apartment)
      create(:employee, user: user, condominium: condominium)

      expect(user.related_condominia).to contain_exactly(condominium)
    end

    it 'returns all related condominiums from different relationships' do
      resident_condo = create(:condominium)
      employee_condo = create(:condominium)

      apartment = create(:apartment, condominium: resident_condo)
      create(:resident, user: user, apartment: apartment)
      create(:employee, user: user, condominium: employee_condo)

      expect(user.related_condominia).to contain_exactly(resident_condo, employee_condo)
    end
  end
end
