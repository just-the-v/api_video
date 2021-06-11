# frozen_string_literal: true

json.extract! video, :id, :created_at, :views, :enabled
json.source "http://localhost:3000#{video.source.url}"
json.user do
  json.partial! 'users/show', user: video.user
end
json.format video.versions
