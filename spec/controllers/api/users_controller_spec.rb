require 'spec_helper'

describe Api::UsersController do

  before do
    User.destroy_all
  end

  describe "create" do
    it "requires authentication" do
      post :create, { username: 'foo', password: 'secret'}
      expect(response.status).to eql 403 # forbidden
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it "creates and returns a new user from username and password params" do
        params = { 'username' => 'testuser', 'password' => 'testpass' }

        expect{ post :create, params }
          .to change{ User.where(params).count }
          .by 1

        expect(JSON.parse(response.body)).to eql params
      end

      it "returns an error when not given a password" do
        post :create, { username: 'testuser' }
        expect(response.status).to eql 422 # unprocessable entity
      end

      it "returns an error when not given a username" do
        post :create, { password: 'testpass' }
        expect(response.status).to eql 422 # unprocessable entity
      end
    end
  end

  describe "index" do
    before do 
      (1..3).each{ |n| User.create( id: n, username: "name#{n}", password: "pass#{n}" ) }
    end

    it "requires authentication" do
      get :index
      expect(response.status).to eql 403 # forbidden
    end

    context "with authentication" do
      before do
        with_authentication
      end

      it "lists all usernames and ids" do
        get :index

        expect(JSON.parse(response.body)).to eql( 
          { 'users' => 
            [
              { 'id' => 1, 'username' => 'name1' },
              { 'id' => 2, 'username' => 'name2' },
              { 'id' => 3, 'username' => 'name3' }
            ]
          })
      end
    end
  end
end