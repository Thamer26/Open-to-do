require 'spec_helper'

describe Api::ListsController do 
  let(:user) { create :user }

  describe "create" do
    let(:params) { { user_id: user.id, name: 'mylist', permissions: 'open', password: user.password } }
    context "with correct user's password" do
      it "takes a list name, creates it if it doesn't exist" do
        expect{ post :create, params }
          .to change{ user.lists.where(name: 'mylist').count }
          .by 1
      end

      it "returns new list params" do
        post :create, params
        result = JSON.parse response.body
        expect(result).to eql( 'id' => 1, 'name' => 'mylist', 'permissions' => 'open' )
      end

      it "returns false if it exists" do
        user.lists.create name: 'mylist'
        expect{ post :create, params }
          .to change{ user.lists.where(name: 'mylist').count }
          .by 0
        expect(response.status).to eql 422 # unprocessable entity
        expect(response.body).to include "Name has already been taken"
      end
    end

    it "requires correct user's password" do
      post :create, params.merge( password: 'wrong' )
      expect(response.status).to eql 403 # forbidden
    end

    it "requires valid user id" do
      post :create, params.merge( user_id: 42 )
      expect(response.status).to eql 404 #not found
    end
  end

  describe "index" do
    before do
      user.lists.create name: "list1", permissions: 'private'
      user.lists.create name: "list2", permissions: 'viewable'
      user.lists.create name: "list3", permissions: 'open'
    end

    context "with correct user's password" do
      it "returns all lists associated with the user" do
        get :index, { user_id: user.id, password: user.password }
        result = JSON.parse(response.body) 
        expect(result).to eql( 
          { 'lists' => 
            [
              { 'id' => 1, 'name' => 'list1', 'permissions' => 'private' },
              { 'id' => 2, 'name' => 'list2', 'permissions' => 'viewable' },
              { 'id' => 3, 'name' => 'list3', 'permissions' => 'open' }
            ]
          })
      end
    end

    context "without correct user's password" do
      let(:expected) { 
        { 'lists' => [ 
          { 'id' => 2, 'name' => 'list2', 'permissions' => 'viewable' },
          { 'id' => 3, 'name' => 'list3', 'permissions' => 'open' } 
        ] } 
      }

      it "returns all visible and open lists when no password" do
        get :index, { user_id: user.id }
        result = JSON.parse(response.body) 
        expect(result).to eql(expected)
      end

      it "returns all visible and open lists when incorrect password" do
        get :index, { user_id: user.id, password: 'incorrect' }
        result = JSON.parse(response.body) 
        expect(result).to eql(expected)
      end
    end

    it "requires valid user id" do
      get :index, { user_id: 42 }
      expect(response.status).to eql 404 #not found
    end
  end
end