class Block < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :content_block
  has_many :contents

  accepts_nested_attributes_for :contents, allow_destroy: true
end
