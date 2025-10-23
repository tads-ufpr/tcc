require 'rails_helper'

RSpec.describe Notice, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:creator).class_name('Employee') }
    it { is_expected.to belong_to(:apartment) }
  end

  describe "validations" do
    it "is valid when creator and apartment belong to the same condominium" do
      condominium = create(:condominium)
      apartment = create(:apartment, condominium:)
      creator = create(:employee, condominium:)
      notice = build(:notice, apartment:, creator:)
      expect(notice).to be_valid
    end

    it "is invalid whencreator and apartment belong to different condominiums" do
      apartment = create(:apartment)
      creator = create(:employee)
      notice = build(:notice, apartment:, creator:)
      expect(notice).not_to be_valid
      expect(notice.errors[:creator]).to include("Creator doesn't belongs to the apartment's condominium")
    end
  end

  describe 'status transitions' do
    context 'with :pending' do
      let(:notice) { create(:notice, status: :pending) }

      it 'can transition to acknowledged' do
        expect(notice.update(status: :acknowledged)).to be true
        expect(notice.status).to eq('acknowledged')
      end

      it 'can transition to resolved' do
        expect(notice.update(status: :resolved)).to be true
        expect(notice.status).to eq('resolved')
      end

      it 'can transition to blocked' do
        expect(notice.update(status: :blocked)).to be true
        expect(notice.status).to eq('blocked')
      end
    end

    context 'with :acknowledged' do
      let(:notice) { create(:notice, status: :acknowledged) }

      it 'can transition to resolved' do
        expect(notice.update(status: :resolved)).to be true
        expect(notice.status).to eq('resolved')
      end

      it 'can transition to blocked' do
        expect(notice.update(status: :blocked)).to be true
        expect(notice.status).to eq('blocked')
      end

      it 'cannot transition to pending' do
        expect(notice.update(status: :pending)).to be false
        expect(notice.errors[:status]).to include('Invalid status transition from acknowledged to pending')
        expect(notice.reload.status).to eq('acknowledged')
      end
    end

    context 'with :resolved' do
      let(:notice) { create(:notice, status: :resolved) }

      it 'cannot transition to :resolved' do
        expect(notice.update(status: :pending)).to be false
        expect(notice.errors[:status]).to include('Invalid status transition from resolved to pending')
        expect(notice.reload.status).to eq('resolved')
      end

      it 'cannot transition to :acknowledged' do
        expect(notice.update(status: :acknowledged)).to be false
        expect(notice.errors[:status]).to include('Invalid status transition from resolved to acknowledged')
        expect(notice.reload.status).to eq('resolved')
      end

      it 'cannot transition to :blocked' do
        expect(notice.update(status: :blocked)).to be false
        expect(notice.errors[:status]).to include('Invalid status transition from resolved to blocked')
        expect(notice.reload.status).to eq('resolved')
      end
    end

    context 'with :blocked' do
      let(:notice) { create(:notice, status: :blocked) }

      it 'can transition to resolved' do
        expect(notice.update(status: :resolved)).to be true
        expect(notice.status).to eq('resolved')
      end

      it 'cannot transition to pending' do
        expect(notice.update(status: :pending)).to be false
        expect(notice.errors[:status]).to include('Invalid status transition from blocked to pending')
        expect(notice.reload.status).to eq('blocked')
      end

      it 'cannot transition to acknowledged' do
        expect(notice.update(status: :acknowledged)).to be false
        expect(notice.errors[:status]).to include('Invalid status transition from blocked to acknowledged')
        expect(notice.reload.status).to eq('blocked')
      end
    end
  end
end
