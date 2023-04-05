# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :sellered_by, ->(username) { where(user: User.where(username: username)) }
  scope :favorited_by, ->(username) { joins(:favorites).where(favorites: { user: User.where(username: username) }) }

  acts_as_taggable

  validates :title, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false
  validates :slug, uniqueness: true, exclusion: { in: ['feed'] }

  before_create do
    self.image = generate_image(self.title) if self.image == ""
  end
  
  before_validation do
    self.slug ||= "#{title.to_s.parameterize}-#{rand(36**6).to_s(36)}"
  end

  private

  require 'openai'

    def generate_image(title)
      client = OpenAI::Client.new(access_token: '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')
      response = client.images.generate(parameters: { prompt: title})
      return response.dig("data", 0, "url")
    end
end
