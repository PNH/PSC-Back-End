class LevelChecklist < ActiveRecord::Base

  belongs_to :level

  validates :level_id, presence: true, numericality: { only_integer: true }
  validates :title, presence: true, length: { maximum: 50 }    # Replace FILL_IN with the right code.
  validates_associated :level

end
