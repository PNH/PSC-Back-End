class Post < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :forum
end
