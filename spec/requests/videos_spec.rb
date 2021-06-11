# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'
VIDEO_PATH = "#{Rails.public_path}/mockup_video.mov"

RSpec.describe 'Videos', type: :request do
  describe '07 - video creation POST /user/:user_id/video' do
    let!(:user) { create(:user) }
    let!(:video_attributes) { attributes_for(:video, user: user) }
    let!(:source) { Rack::Test::UploadedFile.new(VIDEO_PATH, 'form/data') }

    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    after(:each) do
      Video.destroy_all
    end

    it '201 if created successfully ' do
      post user_videos_path(user.id), params: { name: video_attributes[:name], source: source }, headers: @headers
      expect(response).to have_http_status(:created)
    end

    it 'it create the video and add it to user ' do
      post user_videos_path(user.id), params: { name: video_attributes[:name], source: source }, headers: @headers
      expect(user.videos.size).to eq 1
    end

    it 'default name if missing name' do
      post user_videos_path(user.id), params: { source: source }, headers: @headers
      expect(response).to have_http_status(:created)
      expect(user.videos.last.name.empty?).to eq false
    end

    it '400 if missing source' do
      post user_videos_path(user.id), params: { name: video_attributes[:name] }, headers: @headers
      expect(response).to have_http_status(:bad_request)
    end

    it '401 if missing auth' do
      post user_videos_path(user.id), params: { name: video_attributes[:name] }, headers: {}
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '08 - video list GET /videos' do
    let!(:videos) { create_list(:video, 15) }

    it '200 if nothing is submitted' do
      get '/videos'
      expect(response).to have_http_status(:ok)
    end

    it 'render all videos by 5' do
      get '/videos'
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data', 'pager'
      expect(json['data'].size).to eq(5)
      expect(json['pager']).to include 'current', 'total'
    end

    it 'must render all informations' do
      get '/videos'
      json = JSON.parse(response.body)
      first_video = json['data'][0]
      expect(first_video).to include 'id', 'source', 'created_at', 'views', 'enabled', 'user', 'format'
    end

    describe 'page params' do
      let(:uri) { '/videos?page=' }
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
      let(:uri) { '/videos?perPage=' }

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

    describe 'name params' do
      let(:uri) { '/videos?name=' }

      it '400 when is given but empty' do
        get uri
        expect(response).to have_http_status(:bad_request)
      end

      it 'must search for videos with only name matching' do
        random_name = 'Prout prout'
        create(:video, name: random_name)
        get "#{uri}#{random_name}"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(1)
      end

      it 'must handle when there is several videos' do
        create(:video, name: '14DUMAT')
        create(:video, name: 'DumAt314')
        create(:video, name: '41dumat10')
        get "#{uri}dumat"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(3)
      end

      it 'must return data with correct name' do
        video = create(:video, name: 'CECI EST UNN OM ASLDA')
        get "#{uri}CECI EST"
        json = JSON.parse(response.body)
        expect(json['data'][0]['id']).to eq(video.id)
      end
    end

    describe 'duration params' do
      let(:uri) { '/videos?duration=' }
      let!(:short_videos) { create_list(:video, 2, duration: 2)}

      it '400 when is given but empty' do
        get uri
        expect(response).to have_http_status(:bad_request)
      end

      it 'must return all videos with the exact same duration' do
        get "#{uri}2"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(2)
      end

      it 'must empty array if no match' do
        get "#{uri}10"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(0)
      end
    end

    describe 'user params' do
      let(:uri) { '/videos?user=' }
      let!(:user) { create(:user, username: 'PabloPicasso') }
      let!(:user_videos) { create_list(:video, 3, user: user) }

      it '400 when is given but empty' do
        get uri
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an empty array if no matches' do
        get "#{uri}labeuhdamsterdam"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(0)
      end

      it 'returns all videos that my user created' do
        get "#{uri}pablopicasso"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(user_videos.size)
      end

      it 'returns all videos that username matches' do
        new_user = create(:user, username: 'PabloLartiste')
        create(:video, user: new_user)
        get "#{uri}pablo"
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(user_videos.size + 1)
      end
    end
  end

  describe '09 - video list by user GET /user/:id/videos' do
    let!(:user) { create(:user) }
    let!(:videos) { create_list(:video, 3, user: user) }

    it '200 if all right' do
      get videos_user_path(user.id)
      expect(response).to have_http_status(:ok)
    end

    it 'returns all videos of user' do
      get videos_user_path(user.id)
      json = JSON.parse(response.body)
      expect(json['data'].size).to eq(user.videos.size)
    end

    it 'render all videos by 5' do
      create_list(:video, 20, user: user)
      get videos_user_path(user.id)
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data', 'pager'
      expect(json['data'].size).to eq(5)
      expect(json['pager']).to include 'current', 'total'
    end

    describe 'page params' do
      let(:uri) { "/user/#{user.id}/videos?page=" }
      let!(:more_videos) { create_list(:video, 20, user: user) }

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
      it 'do not show same videos at different pages' do
        get "#{uri}1"
        first_video_id = JSON.parse(response.body)['data'][0]['id']
        get "#{uri}2"
        sixth_video_id = JSON.parse(response.body)['data'][0]['id']
        expect(first_video_id == sixth_video_id).to eq(false)
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
      let(:uri) { "/user/#{user.id}/videos?perPage=" }
      let!(:more_videos) { create_list(:video, 20, user: user) }

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

      it 'do not show same quantity of video' do
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
  end

  describe '10 - encoding video by id PATCH /video/:id' do
    before(:all) do
      @user = create(:user)
      source = Rack::Test::UploadedFile.new(VIDEO_PATH, 'form/data')
      video_attributes = attributes_for(:video, user: @user)
      post auth_index_path, params: { login: @user.email, password: 'password' }
      @headers = { Authorization: "Bearer #{JSON.parse(response.body)['data']}" }
      post user_videos_path(@user.id), params: { name: video_attributes[:name], source: source }, headers: @headers
      @video = Video.last
    end

    after(:all) do
      Video.destroy_all
    end

    it '200 in case of sucess' do
      patch "/video/#{@video.id}", params: { resolution: '1080', file: 'test' }
      expect(response).to have_http_status(:ok)
    end

    it 'render the view of video updated' do
      patch "/video/#{@video.id}", params: { resolution: '720', file: 'test' }
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data'
      expect(json['data']).to include 'format'
      expect(json['data']['format']).to include '720'
    end

    it 'created a file format and set it to the remain video' do
      patch "/video/#{@video.id}", params: { resolution: '1080', file: 'test' }
      expect(@video.video_formats.size).to eq(1)
    end

    it 'created a file format and respect the resolution' do
      patch "/video/#{@video.id}", params: { resolution: '1080', file: 'test' }
      expect(@video.video_formats[0].resolution).to eq('1080')
    end

    it '404 if video does not exist' do
      patch '/video/0', params: { resolution: '1080', file: 'test' }
      expect(response).to have_http_status(:not_found)
    end

    it '400 when i submit a not whitelisted resolution' do
      patch "/video/#{@video.id}", params: { resolution: '32432', file: 'test' }
      expect(response).to have_http_status(:bad_request)
    end

    it '400 when i submit other than integer' do
      patch "/video/#{@video.id}", params: { resolution: 'prout', file: 'test' }
      expect(response).to have_http_status(:bad_request)
    end

    it '400 when i not submit resolution' do
      patch "/video/#{@video.id}", params: { file: 'test' }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe '11 - video update PUT /video/:id' do
    let!(:user) { create(:user) }
    let!(:video) { create(:video, user: user) }

    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    it '200 when success' do
      put "/video/#{video.id}", params: {}, headers: @headers
      expect(response).to have_http_status(:ok)
    end

    it 'render a normal show' do
      put "/video/#{video.id}", params: {}, headers: @headers
      json = JSON.parse(response.body)
      expect(json).to include 'message', 'data'
      expect(json['data']).to include 'id', 'created_at', 'source', 'views', 'enabled', 'user', 'format'
    end

    # it 'change the name of the video' do # TODO
    #   random_name = 'WOE LE BOSS'
    #   put "/video/#{video.id}", params: { name: random_name }, headers: @headers
    #   expect(Video.find(video.id).name).to eq(random_name)
    # end

    it 'change the owner of the video' do
      new_user = create(:user)
      put "/video/#{video.id}", params: { user: new_user.id }, headers: @headers
      expect(Video.find(video.id).user).to eq(new_user)
    end

    it '401 when you changed the user and try to update it again' do
      new_user = create(:user)
      put "/video/#{video.id}", params: { user: new_user.id }, headers: @headers
      put "/video/#{video.id}", params: { user: user.id }, headers: @headers
      expect(response).to have_http_status(:unauthorized)
    end

    it '401 when you try but you are not the owner' do
      new_video = create(:video)
      put "/video/#{new_video.id}", params: {}, headers: @headers
      expect(response).to have_http_status(:unauthorized)
    end

    it '401 when auth is not submitted' do
      put "/video/#{video.id}", params: {}, headers: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it '404 when video not found' do
      put '/video/0', params: {}, headers: @headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '12 - video deletion DELETE /video/:id' do
    let!(:user) { create(:user) }
    let!(:video) { create(:video, user: user) }

    before(:each) do
      post auth_index_path, params: { login: user.email, password: 'password' }
      json = JSON.parse(response.body)
      @headers = { Authorization: "Bearer #{json['data']}" }
    end

    it '204 when success' do
      delete video_path(video.id), headers: @headers
      expect(response).to have_http_status(:no_content)
    end

    it 'really destroy video in database' do
      delete video_path(video.id), headers: @headers
      expect(Video.count).to eq(0)
    end


    it '404 if video not found' do
      delete video_path(111111111), headers: @headers
      expect(response).to have_http_status(:not_found)
    end

    it '401 when you try but you are not the owner' do
      new_video = create(:video)
      delete video_path(new_video.id), headers: @headers
      expect(response).to have_http_status(:unauthorized)
    end

    it '401 when auth is not submitted' do
      delete video_path(video.id), headers: {}
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

