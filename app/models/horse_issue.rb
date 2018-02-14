class HorseIssue < ActiveRecord::Base
  belongs_to :horse
  belongs_to :issue
end
