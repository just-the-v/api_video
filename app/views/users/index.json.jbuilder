# frozen_string_literal: true

json.message 'OK'
json.data do
  json.array! @users.each do |user|
    json.partial! 'show', user: user
  end
end

json.partial! 'pager', model: @users
