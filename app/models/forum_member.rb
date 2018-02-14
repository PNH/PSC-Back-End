class ForumMember < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :forum
  belongs_to :user
end
