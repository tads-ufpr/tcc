class ApartmentSerializer < ActiveModel::Serializer
  attributes :id, :floor, :number, :tower, :created_at, :updated_at
end
