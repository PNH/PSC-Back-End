class HorseProgress < ActiveRecord::Base
  has_one :wall, as: :wallposting
  has_many :horse_progress_logs, :dependent => :destroy
  belongs_to :horse
end
