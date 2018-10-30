def with_authentication
  Api::UsersController.any_instance.stub(:authenticated?) { true }
end
