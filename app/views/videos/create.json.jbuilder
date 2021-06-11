# frozen_string_literal: true

json.message 'OK'
json.data do
  json.partial! 'videos/show', video: @video
end
