class Playlist < ActiveRecord::Base
  acts_as_paranoid

  has_one :group_post, as: :groupposting
  has_one :wall, as: :wallposting
  belongs_to :user
  has_many :playlist_resources
  has_many :lesson_resources, through: :playlist_resources
end
