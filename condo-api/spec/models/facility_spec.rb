require 'rails_helper'

RSpec.describe Facility, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:condominium) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:tax).only_integer.is_greater_than_or_equal_to(0) }
  end
end
