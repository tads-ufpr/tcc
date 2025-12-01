require 'rails_helper'

RSpec.describe Facility, type: :model do
  describe 'associations' do
    it { should belong_to(:condominium) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:tax) }
    it { should validate_numericality_of(:tax).only_integer.is_greater_than_or_equal_to(0) }
  end
end