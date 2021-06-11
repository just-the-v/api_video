# frozen_string_literal: true

class VideoFormat < ApplicationRecord
  mount_uploader :source, VideoUploader
  belongs_to :video

  validate :valid_resolution

  def valid_resolution
    return if Global::RESOLUTIONS.include?(resolution.to_i)

    errors.add(:resolution, "Resolution must be a value of #{Global::RESOLUTIONS}")
  end
end
