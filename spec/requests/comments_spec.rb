require 'rails_helper'

RSpec.describe "Comments", type: :request do
  describe "13 - comment creation POST /video/:id/comment" do
    let!(:video) { create(:video) }
    let!(:user) { video.user }
    let!(:comment_attributes) { attributes_for(:comment, user: user, video: video) }

    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    it '201 if successfully created' do
      post video_comments_path(video.id), params: { body: comment_attributes[:body] }, headers: @headers
      expect(response).to have_http_status(:created)
    end

    it 'it created the resource for real' do
      post video_comments_path(video.id), params: { body: comment_attributes[:body] }, headers: @headers
      expect(user.comments.size).to eq(1)
    end

    it 'it render the comment that been created' do
      post video_comments_path(video.id), params: { body: comment_attributes[:body] }, headers: @headers
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data'
      expect(json['data']).to include 'id', 'user', 'body'
    end

    it '404 if video not found' do
      post video_comments_path(0), params: { body: comment_attributes[:body] }, headers: @headers
      expect(response).to have_http_status(:not_found)
    end

    it '401 if no auth' do
      post video_comments_path(video.id), params: { body: comment_attributes[:body] }, headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it '400 if body empty' do
      post video_comments_path(video.id), params: {}, headers: @headers
      expect(response).to have_http_status(:bad_request)
    end

    it 'can create planty of commentaries' do
      5.times do
        post video_comments_path(video.id), params: { body: comment_attributes[:body] }, headers: @headers
      end
      expect(user.comments.size).to eq(5)
    end
  end

  describe '14 - comment list GET /video/:id/comments' do
    let!(:user) { create(:user) }
    let!(:video) { create(:video) }
    let!(:random_comments) { create_list(:comment, 25, video: video) }

    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    it 'render all comments by 5' do
      get "/video/#{video.id}/comments", headers: @headers
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data', 'pager'
      expect(json['data'].size).to eq(5)
      expect(json['pager']).to include 'current', 'total'
    end

    it '401 if no auth' do
      get "/video/#{video.id}/comments", headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it '404 if video not found' do
      get "/video/0/comments", headers: @headers
      expect(response).to have_http_status(:not_found)
    end

    describe 'page params' do
      let(:uri) { "/video/#{video.id}/comments?page=" }
      let!(:more_comments) { create_list(:comment, 20, video: video) }

      it '400 when is given but empty' do
        get uri, headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but not a number' do
        get "#{uri}sadas", headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but negative' do
        get "#{uri}-50", headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when page is higher than maximum page' do
        get "#{uri}1000000", headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when page is 0' do
        get "#{uri}0", headers: @headers
        expect(response).to have_http_status(:bad_request)
      end
      it 'do not show same comment at different pages' do
        get "#{uri}1", headers: @headers
        first_video_id = JSON.parse(response.body)['data'][0]['id']
        get "#{uri}2", headers: @headers
        sixth_video_id = JSON.parse(response.body)['data'][0]['id']
        expect(first_video_id == sixth_video_id).to eq(false)
      end
      it 'change the current of pager' do
        get "#{uri}1", headers: @headers
        first_current = JSON.parse(response.body)['pager']['current']
        get "#{uri}2", headers: @headers
        second_current = JSON.parse(response.body)['pager']['current']
        expect(first_current == second_current).to eq(false)
      end
    end

    describe 'per_page params' do
      let(:uri) { "/video/#{video.id}/comments?perPage=" }
      let!(:more_comments) { create_list(:comment, 20, video: video) }

      it '400 when is given but empty' do
        get uri, headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but not a number' do
        get "#{uri}sadas", headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it '400 when is given but negative' do
        get "#{uri}-50", headers: @headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'do not show same quantity of video' do
        get "#{uri}5", headers: @headers
        first_size = JSON.parse(response.body)['data'].size
        get "#{uri}15", headers: @headers
        second_size = JSON.parse(response.body)['data'].size
        expect(first_size == second_size).to eq(false)
      end

      it 'change the total of pager' do
        get "#{uri}1", headers: @headers
        first_total = JSON.parse(response.body)['pager']['total']
        get "#{uri}10", headers: @headers
        second_total = JSON.parse(response.body)['pager']['total']
        expect(first_total == second_total).to eq(false)
      end
    end
  end
end
