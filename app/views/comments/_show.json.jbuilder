json.extract! comment, :id, :body
json.user do
  json.partial! 'users/show', user: comment.user
end
