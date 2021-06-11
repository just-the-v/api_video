# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auths', type: :request do
  describe '02 - authentication POST /auth' do
    let!(:user) { create(:user) }

    describe 'good path' do
      it 'return http success' do
        post auth_index_path, params: { login: user.email, password: 'password' }
        expect(response).to have_http_status(:success)
      end

      it 'return OK + token' do
        post auth_index_path, params: { login: user.email, password: 'password' }
        json = JSON.parse(response.body)
        expect(json).to include('data', 'message')
        expect(json['message']).to eq('OK')
      end
    end

    describe 'missing or bad params' do
      it '404 when login not found' do
        post auth_index_path, params: { login: 'prout', password: 'password' }
        expect(response).to have_http_status(:not_found)
      end

      it '401 when password not match' do
        post auth_index_path, params: { login: user.email, password: 'paslebon' }
        expect(response).to have_http_status(:unauthorized)
      end

      it '400 when missing login' do
        post auth_index_path, params: { password: 'password' }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['data']).to include("Login can't be blank")
      end

      it '400 when missing password' do
        post auth_index_path, params: { login: 'password' }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['data']).to include("Password can't be blank")
      end
    end
  end
end
