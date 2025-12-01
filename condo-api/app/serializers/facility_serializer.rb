class FacilitySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :tax, :condominium_id
end
