# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def normalize(string)
    return '' unless string.present?

    string.underscore.gsub(' ', '_')
  end
end
