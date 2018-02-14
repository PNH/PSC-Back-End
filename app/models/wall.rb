class Wall < ActiveRecord::Base
  has_many :wall_post_comment, :dependent => :destroy
  has_many :wall_post_attachment, :dependent => :destroy
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :wallposting, polymorphic: true
  has_many :wall_post_like, :dependent => :destroy

  belongs_to :horse_progress, -> { where(walls: {wallposting_type: 'HorseProgress'}) }, foreign_key: 'wallposting_id'
  belongs_to :horse_health, -> { where(walls: {wallposting_type: 'HorseHealth'}) }, foreign_key: 'wallposting_id'

end
