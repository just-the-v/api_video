# frozen_string_literal: true

class Video < ApplicationRecord
  mount_uploader :source, VideoUploader, dependant: :destroy
  belongs_to :user
  has_many :video_formats, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_destroy :remember_id
  before_validation :set_default_name_value
  after_destroy :remove_id_directory
  before_update :change_directory_name, if: ->(video) { video.name_changed? }

  def set_default_name_value
    self.name = "New Video from #{user.username}-#{DateTime.now.strftime('%A %B %Y')}" if name.blank?
  end

  def change_directory_name
    return if source.file.path == '/app/public/uploads/_/t' || source.file.path.blank?

    base_path = "#{Rails.public_path}/uploads/#{id}"
    File.rename "#{base_path}_#{normalize name_was}", "#{base_path}_#{normalize name}"
  end

  def remember_id
    @id = id
    @name = name.underscore
  end

  def remove_id_directory
    FileUtils.remove_dir("#{Rails.public_path}/uploads/#{@id}_#{normalize @name}", force: true)
  end

  def versions
    video_formats.reduce([]) { |memo, acc| memo << [acc.resolution, "http://localhost:3000#{acc.source.url}"] }.to_h
  end

  def set_duration
    update(duration: FFMPEG::Movie.new(source.path).duration)
  end
end
