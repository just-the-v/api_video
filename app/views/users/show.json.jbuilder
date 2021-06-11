# frozen_string_literal: true

json.message 'OK'
json.data do
  json.partial! 'show', user: @user
end
