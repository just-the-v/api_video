# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :videos, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates_presence_of :email, :username
  validates_uniqueness_of :email
  validates_format_of :username, with: /[a-zA-Z0-9_-]/, message: 'accept only letters and numbers'

  def self.search(username)
    where("username ILIKE '%#{username}%'")
  end
end
