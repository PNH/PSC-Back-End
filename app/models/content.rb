# frozen_string_literal: true
class Content < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :block
  enum kind: [:image, :text, :string, :video, :file, :number, :html]


  def input_html
    hash = read_attribute(:input_html)
    return {} if hash.blank?
    JSON.parse(hash)
  end
end
