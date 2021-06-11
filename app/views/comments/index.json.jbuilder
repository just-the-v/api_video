# frozen_string_literal: true

json.message 'OK'
json.data do
  json.array! @comments.each do |comment|
    json.partial! 'comments/show', comment: comment
  end
end

json.partial! 'pager', model: @comments
