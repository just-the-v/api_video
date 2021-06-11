# frozen_string_literal: true

module IndexBuilder
  class Base
    attr_accessor :page, :per_page, :errors

    def initialize(params)
      @page = params[:page]
      @per_page = params[:perPage]
      @errors = []
    end

    def perform
      validate_pagination_params
      return self if @errors.any?

      default_variables_index
    end

    def default_variables_index
      @page = @page&.to_i || 1
      @per_page = @per_page&.to_i || 5
    end

    def validate_pagination_params
      @errors << 'Page must be an integer' if @page && !@page.match(/[0-9]/)
      @errors << 'Page must be positive' if @page&.match(/[0-9]/) && @page.to_i <= 0
      @errors << 'PerPage must be an integer' if @per_page && !@per_page.match(/[0-9]/)
      @errors << 'PerPage must be positive' if @per_page&.match(/[0-9]/) && @per_page.to_i <= 0
    end
  end
end
