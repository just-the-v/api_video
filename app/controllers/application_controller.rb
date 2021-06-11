# frozen_string_literal: true

class ApplicationController < ActionController::API
  JWT_SECRET = ENV['JWT_SECRET']
  before_action :authorized
  skip_before_action :authorized, only: %i[render_not_found]
  rescue_from ActionController::UrlGenerationError, with: :render_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def render_not_found
    render json: { message: 'Not found' }, status: :not_found
  end

  def render_bad_request(full_messages)
    render json: { message: 'Bad Request', data: full_messages }, status: :bad_request
  end

  def encode_token(payload)
    JWT.encode(payload, JWT_SECRET)
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    return unless auth_header

    token = auth_header.split(' ')[1]
    JWT.decode(token, JWT_SECRET, true, algorithm: 'HS256')
  rescue JWT::DecodeError
    nil
  end

  def logged_in_user
    token = decoded_token
    return unless token

    user_id = token[0]['user_id']
    @current_user = User.find_by(id: user_id)
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render_unauthorized unless logged_in?
  end

  def render_unauthorized
    render json: { message: 'Unauthorized' }, status: :unauthorized
  end
end
