# frozen_string_literal: true

module IndexBuilder
  class UserVideos < Base
    attr_accessor :videos, :id

    def initialize(params)
      @id = params[:id]
      super
    end

    def perform
      super
      videos = Video.where(user_id: @id)
      @videos = videos.page(@page).per(@per_page)
      self
    end
  end
end
