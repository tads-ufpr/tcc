class ApartmentSerializer < ActiveModel::Serializer
  attributes :id, :floor, :number, :tower, :status, :created_at, :updated_at

  has_many :residents
end
