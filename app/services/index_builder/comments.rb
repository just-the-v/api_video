# frozen_string_literal: true

module IndexBuilder
  class Comments < Base
    attr_accessor :comments, :video_id

    def initialize(params)
      @video_id = params[:video_id]
      super
    end

    def perform
      super
      comments = Comment.where(video_id: @video_id)
      @comments = comments.page(@page).per(@per_page)
      self
    end
  end
end
