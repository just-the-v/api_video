# frozen_string_literal: true

class VideosController < ApplicationController
  skip_before_action :authorized, only: %i[index encode show_by_user]
  before_action :logged_in_user, only: %i[index encode show_by_user]
  before_action :set_video, only: %i[encode update destroy]

  def index
    builder = IndexBuilder::Videos.new(params).perform
    return render_bad_request(builder.errors) if builder.errors.any?

    @videos = builder.videos
    render_bad_request(['Page must lower than maximum']) if @videos.out_of_range? && builder.page > 1
  end

  def show_by_user
    builder = IndexBuilder::UserVideos.new(params).perform
    return render_bad_request(builder.errors) if builder.errors.any?

    @videos = builder.videos
    if @videos.out_of_range? && builder.page > 1
      render_bad_request(['Page must lower than maximum'])
    else
      render template: 'videos/index', status: :ok
    end
  end

  def create
    return render_unauthorized unless params[:user_id].to_i == @current_user.id
    return render_bad_request(['Source must be present']) unless params[:source].present?

    @video = Video.new(video_params)
    if @video.save
      render template: 'videos/create', status: :created
    else
      render_bad_request(@video.errors.full_messages)
    end
  end

  def encode
    @format = VideoFormat.where(video: @video, resolution: params[:resolution]).first
    return render template: 'videos/create', status: :ok unless @format.nil?

    @format = VideoFormat.new(**encode_params, video: @video)
    if @format.save
      @format.source = @video.source.file.dup
      @format.save
      render template: 'videos/create', status: :ok
    else
      render_bad_request(@format.errors.full_messages)
    end
  end

  def update
    return render_unauthorized unless @current_user.id == @video.user.id

    if @video.update(update_params)
      render template: 'videos/create', status: :ok
    else
      render_bad_request(@video.errors.full_messages)
    end
  end

  def destroy
    return render_unauthorized unless @current_user.id == @video.user.id

    @video.destroy
    head :no_content
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end

  def video_params
    params.permit(:source, :name, :user_id)
  end

  def update_params
    h = {}
    h.merge!({ name: params[:name] }) if params[:name]
    h.merge!({ user_id: params[:user] }) if params[:user]
    h
  end

  def encode_params
    params.permit(:resolution, :file)
  end
end
