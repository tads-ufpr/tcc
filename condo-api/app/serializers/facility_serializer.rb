class FacilitySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :tax
  has_one :condominium
end
