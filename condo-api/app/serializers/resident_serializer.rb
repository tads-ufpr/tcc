class ResidentSerializer < ActiveModel::Serializer
  attributes :id, :owner, :user_id, :user_name

  def user_name
    object.user.name
  end
end
