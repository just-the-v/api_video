# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authorized, only: %i[create index]
  before_action :logged_in_user, only: %i[index]

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render template: 'users/create', status: :created
    else
      render_bad_request(@user.errors.full_messages)
    end
  end

  def update
    return render_unauthorized unless @current_user.id == params[:id].to_i

    if @current_user.update(user_params)
      @user = @current_user
      render template: 'users/create', status: :ok
    else
      render_bad_request(@current_user.errors.full_messages)
    end
  end

  def destroy
    return render_unauthorized unless @current_user.id == params[:id].to_i

    @current_user.destroy
    head :created
  end

  def index
    builder = IndexBuilder::Users.new(params).perform
    return render_bad_request(builder.errors) if builder.errors.any?

    @users = builder.users
    render_bad_request(['Page must lower than maximum']) if @users.out_of_range? && builder.page > 1
  end

  private

  def user_params
    params.permit(:username, :password, :email, :pseudo)
  end
end
