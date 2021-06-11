# frozen_string_literal: true

json.extract! user, :id, :username, :pseudo, :created_at
json.email user.email if @current_user&.id == user.id
