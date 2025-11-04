class CondominiumSerializer < ActiveModel::Serializer
  attributes :id,
    :name, :zipcode,
    :city, :state, :address,
    :neighborhood, :number,
    :created_at, :updated_at

  has_many :apartments

  def apartments
    if scope
      object.apartments.accessible_by(scope)
    else
      []
    end
  end
end
