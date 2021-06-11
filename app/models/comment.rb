class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :video

  validates_presence_of :body, :user_id, :video_id
end
