# frozen_string_literal: true

module IndexBuilder
  class Videos < Base
    attr_accessor :videos, :name, :duration, :user

    def initialize(params)
      @name = params[:name]
      @duration = params[:duration]
      @user = params[:user]
      super
    end

    def perform
      super
      videos = Video.all
      videos = videos.where("name ILIKE '%#{@name}%'") unless name.blank?
      videos = videos.where(duration: @duration) unless @duration.nil?
      videos = videos.where(user_id: User.search(@user).pluck(:id)) unless @user.blank?
      @videos = videos.page(@page).per(@per_page)
      self
    end

    def default_variables_index
      @duration = @duration&.to_i
      super
    end

    def validate_pagination_params
      @errors << 'Name must be filled' if @name&.empty?
      @errors << 'User must be filled' if @user&.empty?
      @errors << 'Duration must be an integer' if @duration && !@duration.match(/[0-9]/)
      @errors << 'Duration must be positive' if @duration&.match(/[0-9]/) && @duration.to_i <= 0
      super
    end
  end
end
