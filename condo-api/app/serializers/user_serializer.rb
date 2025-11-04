class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :cpf, :phone
end
