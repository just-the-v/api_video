# frozen_string_literal: true

class AuthController < ApplicationController
  skip_before_action :authorized

  def create
    return render_bad_request(error_params) if params[:login].blank? || params[:password].blank?

    user = User.find_by(email: params[:login])
    return render_not_found if user.nil?
    return render_unauthorized unless user.authenticate(params[:password])

    token = encode_token({ user_id: user.id })
    render json: { message: 'OK', data: token }
  end

  private

  def error_params
    errors = []
    errors << "Login can't be blank" if params[:login].blank?
    errors << "Password can't be blank" if params[:password].blank?
    errors
  end
end
