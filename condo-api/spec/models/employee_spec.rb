require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe "associations" do
    subject(:emp) { described_class.new }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:condominium) }

    it do
      expect(emp).to have_many(:created_notices)
        .class_name('Notice')
        .with_foreign_key('creator_id')
        .dependent(:nullify)
        .inverse_of(:creator)
    end
  end
end
