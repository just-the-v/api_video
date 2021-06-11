# frozen_string_literal: true

json.message 'OK'
json.data do
  json.partial! 'comments/show', comment: @comment
end
