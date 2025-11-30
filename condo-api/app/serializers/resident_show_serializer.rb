class ResidentShowSerializer < ResidentSerializer
  attributes :id, :apartment_id, :owner, :created_at, :updated_at

  belongs_to :user do
    object.user.slice(:id, :first_name, :last_name).merge(name: object.user.name)
  end
end
