class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :name, :cpf, :phone
end
