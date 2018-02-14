class HorseProgressLog < ActiveRecord::Base
  belongs_to :horse_progress
  belongs_to :savvy
  belongs_to :level
  
  validates :level_id, presence: true
  validates :savvy_id, presence: true
  validates :time, presence: true
end
