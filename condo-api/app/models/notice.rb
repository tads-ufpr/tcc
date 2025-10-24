class Notice < ApplicationRecord
  belongs_to :apartment
  belongs_to :creator, class_name: "Employee"

  enum :notice_type, {
    delivery: 0,
    visitor: 1,
    maintenance: 2,
    communication: 3
  }, default: :communication

  enum :status, {
    pending: 0,
    acknowledged: 1,
    resolved: 2,
    blocked: 100
  }, default: :pending

  validates :creator, :apartment, :title, :status, :notice_type, presence: true

  validate :status_transition, on: :update
  validate :valid_creator?, on: [:create, :update]

  private

  def valid_creator?
    return unless creator.present? && apartment.present?

    if creator.condominium_id != apartment.condominium_id
      errors.add(:creator, "Creator doesn't belongs to the apartment's condominium")
    end
  end

  def can_transition_to?(new_status)
    allowed_transitions = {
      pending: [:acknowledged, :resolved, :blocked],
      acknowledged: [:resolved, :blocked],
      resolved: [],
      blocked: [:resolved]
    }

    allowed_transitions[status_was.to_sym].include?(new_status)
  end

  def status_transition
    return unless status_changed?
    return if status.blank?

    unless can_transition_to?(status.to_sym)
      errors.add(:status, "Invalid status transition from #{status_was} to #{status}")
    end
  end
end
