# frozen_string_literal: true

module IndexBuilder
  class Users < Base
    attr_accessor :pseudo, :users

    def initialize(params)
      @pseudo = params[:pseudo]
      super
    end

    def perform
      super
      users = @pseudo.blank? ? User.all : User.where("pseudo ILIKE '%#{@pseudo}%'")
      @users = users.page(@page).per(@per_page)
      self
    end

    def default_variables_index
      @pseudo ||= ''
      super
    end

    def validate_pagination_params
      @errors << 'Pseudo must be filled' if @pseudo&.empty?
      super
    end
  end
end
