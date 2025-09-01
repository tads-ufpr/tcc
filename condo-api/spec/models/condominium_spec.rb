require 'rails_helper'

RSpec.describe Condominium, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:zipcode) }
    it { should validate_presence_of(:neighborhood) }
  end
end
