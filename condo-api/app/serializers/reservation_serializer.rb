class ReservationSerializer < ActiveModel::Serializer
  attributes :id, :facility_id, :apartment_id, :creator_id, :scheduled_date, :created_at, :updated_at, :creator

  belongs_to :apartment
  belongs_to :facility

  def creator
    {
      id: object.creator.id,
      name: object.creator.name
    }
  end
end
