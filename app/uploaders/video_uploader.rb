# frozen_string_literal: true

class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video
  storage :file
  after :store, :set_duration

  def normalize(name)
    return nil unless name.present?

    name.underscore.gsub(' ', '_')
  end

  def store_dir
    if model.instance_of? Video
      "uploads/#{model.id}_#{normalize model.name}"
    elsif model.instance_of? VideoFormat
      "uploads/#{model.video.id}_#{normalize model.video.name}"
    else
      "uploads/errors/#{model.id}"
    end
  end

  def filename
    if model.instance_of? Video
      "#{Time.now.to_i}_original.mp4"
    elsif model.instance_of? VideoFormat
      "#{Time.now.to_i}_#{normalize model.file}.mp4"
    else
      "#{Time.now.to_i}_#{model.id}.mp4"
    end
  end

  def encode
    if model.instance_of? Video
      encode_video(:mp4)
    elsif model.instance_of? VideoFormat
      encode_video(:mp4, resolution: "#{model.resolution}x#{model.resolution}")
    end
  end

  def set_duration(_)
    return unless model.instance_of? Video

    model.set_duration
  end

  process :encode
end
