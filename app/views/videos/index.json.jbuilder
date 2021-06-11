# frozen_string_literal: true

json.message 'OK'
json.data do
  json.array! @videos.each do |video|
    json.partial! 'videos/show', video: video
  end
end

json.partial! 'pager', model: @videos
