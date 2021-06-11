# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe '01 - user creation POST /user' do
    let!(:user_attributes) { attributes_for(:user) }

    describe 'when all is good' do
      it 'must create a user if all params are given' do
        post users_path, params: user_attributes
        expect(User.where(email: user_attributes[:email]).size).to eq(1)
      end

      it 'must answer by 201 code' do
        post users_path, params: user_attributes
        expect(response).to have_http_status(:created)
      end

      it 'must give you data of the created user' do
        post users_path, params: user_attributes
        expect(response).to render_template('users/create')
      end
    end

    describe 'make error when missing required params' do
      it 'missing password' do
        post users_path, params: user_attributes.reject { |k, _| k == :password }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)
        expect(json['data']).to include("Password can't be blank")
      end

      it 'missing username' do
        post users_path, params: user_attributes.reject { |k, _| k == :username }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)
        expect(json['data']).to include("Username can't be blank")
      end

      it 'respect [a-zA-Z0-9_-] case for username' do
        user_attributes[:username] = '.,/,/,/.,!@#$!@$'
        post users_path, params: user_attributes
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)

        expect(json['data']).to include('Username accept only letters and numbers')
      end

      it 'cannot create two user with same email' do
        User.destroy_all
        post users_path, params: user_attributes
        post users_path, params: user_attributes
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)
        expect(User.count).to eq(1)
        expect(json['data']).to include('Email has already been taken')
      end

      it 'missing email' do
        post users_path, params: user_attributes.reject { |k, _| k == :email }
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:bad_request)
        expect(json['data']).to include("Email can't be blank")
      end
    end
  end

  describe '03 - user deletion DELETE /user/:id' do
    let!(:user) { create(:user) }
    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    describe 'good path' do
      it '201 if all done' do
        delete user_path(user.id), params: {}, headers: @headers
        expect(response).to have_http_status(:created)
      end

      it 'it destroy the user' do
        size = User.count
        delete user_path(user.id), params: {}, headers: @headers
        expect(User.count).to eq(size - 1)
      end
    end

    it '401 when token is missing' do
      delete user_path(user.id), params: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it '404 when user is not matching' do
      delete user_path(0), params: {}
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '04 - user update PATCH /user/:id' do
    let!(:user) { create(:user) }
    let!(:user_attributes) { attributes_for(:user) }
    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    describe 'good path' do
      it '200 if all done' do
        patch user_path(user.id), params: { username: 'test' }, headers: @headers
        expect(response).to have_http_status(:ok)
      end

      it 'really update user info' do
        patch user_path(user.id), params: user_attributes, headers: @headers
        expect(User.find(user.id)).to have_attributes(username: user_attributes[:username],
                                                      pseudo: user_attributes[:pseudo],
                                                      email: user_attributes[:email])
      end
    end

    it '401 with missing or wrong token' do
      patch user_path(user.id), params: { username: 'test' }, headers: { Authorization: 'Bearer prout' }
      expect(response).to have_http_status(:unauthorized)
    end

    it '401 if id is not matching' do
      patch user_path(0), params: { username: 'test' }, headers: @headers
      expect(response).to have_http_status(:unauthorized)
    end

    it '400 if wrong username' do
      patch user_path(user.id), params: { username: '@#!@$!$@' }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['data']).to include 'Username accept only letters and numbers'
    end
  end

  describe '05 - user list GET /users' do
    let!(:users) { create_list(:user, 25) }

    it '200 if nothing is submitted' do
      get '/users'
      expect(response).to have_http_status(:ok)
    end
    it 'render all users by 5' do
      get '/users'
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data', 'pager'
      expect(json['data'].size).to eq(5)
      expect(json['pager']).to include 'current', 'total'
    end

    describe 'page params' do
      let(:uri) { '/users?page=' }
      it '400 when is given but empty' do
        get uri
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but not a number' do
        get "#{uri}sadas"
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but negative' do
        get "#{uri}-50"
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when page is higher than maximum page' do
        get "#{uri}1000000"
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when page is 0' do
        get "#{uri}0"
        expect(response).to have_http_status(:bad_request)
      end
      it 'do not show same user at different pages' do
        get "#{uri}1"
        first_user_id = JSON.parse(response.body)['data'][0]['id']
        get "#{uri}2"
        sixth_user_id = JSON.parse(response.body)['data'][0]['id']
        expect(first_user_id == sixth_user_id).to eq(false)
      end
      it 'change the current of pager' do
        get "#{uri}1"
        first_current = JSON.parse(response.body)['pager']['current']
        get "#{uri}2"
        second_current = JSON.parse(response.body)['pager']['current']
        expect(first_current == second_current).to eq(false)
      end
    end
    describe 'per_page params' do
      let(:uri) { '/users?perPage=' }
      it '400 when is given but empty' do
        get uri
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but not a number' do
        get "#{uri}sadas"
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but negative' do
        get "#{uri}-50"
        expect(response).to have_http_status(:bad_request)
      end

      it 'do not show same quantity of user' do
        get "#{uri}5"
        first_size = JSON.parse(response.body)['data'].size
        get "#{uri}15"
        second_size = JSON.parse(response.body)['data'].size
        expect(first_size == second_size).to eq(false)
      end

      it 'change the total of pager' do
        get "#{uri}1"
        first_total = JSON.parse(response.body)['pager']['total']
        get "#{uri}10"
        second_total = JSON.parse(response.body)['pager']['total']
        expect(first_total == second_total).to eq(false)
      end
    end

    describe 'pseudo params' do
      let(:uri) { '/users?pseudo=' }

      it '400 when is given but empty' do
        get uri
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns all users found with a pseudos that contain the query' do
        random_pseudo = 'hugodelastreettuconnaisbg'
        create(:user, pseudo: random_pseudo)
        get "#{uri}#{random_pseudo}"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(1)
      end

      it 'returns empty array if there is no match' do
        get "#{uri}unautrepseudotropwtf"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(0)
      end
    end
  end

  describe '06 - user by id GET /user/:id' do
    let!(:user) { create(:user) }
    let!(:other_users) { create_list(:user, 10) }
    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    it '200 if user found and auth' do
      get user_path(other_users.sample.id), params: {}, headers: @headers
      expect(response).to have_http_status(:ok)
    end

    it '401 if no auth' do
      get user_path(other_users.sample.id), params: {}, headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it '404 if wrong user' do
      get user_path(0), params: {}, headers: @headers
      expect(response).to have_http_status(:not_found)
    end

    it 'returns all information of found user' do
      other_user = other_users.sample
      get user_path(other_user.id), params: {}, headers: @headers
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data'
      expect(json['data']).to include 'id', 'username', 'pseudo', 'created_at'
    end
  end
end
