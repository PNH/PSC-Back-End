class Tag < ActiveRecord::Base
  has_many :blog_post_tags, dependent: :destroy
  has_many :blog_posts, through: :blog_post_tags

  has_many :page_tags, dependent: :destroy
  has_many :pages, through: :page_tags

  validates :name, :slug, presence: true

  before_save :update_slug_and_name
  validates_uniqueness_of :slug, :name, case_sensitive: false

  def self.multiple_save(tags_array)
    tag_ids = []
    tags_array.each { |tag|
      # tag_word_array = []
      # tag.gsub('-',' ').split.each do |word|
      #  _word = word.gsub(/[^0-9A-Za-z]/, '')
      #   unless _word == _word.capitalize
      #     _word.downcase!
      #   end
      #   tag_word_array << _word
      # end
      # _name = tag_word_array.join('-')
      # _tag = self.find_or_initialize_by(slug: _name.downcase)

      tag = tag.gsub('-',' ').split.map { |word|
        word.gsub(/[^0-9A-Za-z]/, '')
      }.join('-')
      _tag = self.find_or_initialize_by(slug: tag.downcase)
      _tag.name = tag
      # _tag.name = _name
      _tag.save
      tag_ids << _tag.id
    }
    return tag_ids
  end

  def update_slug_and_name
    slug = self.slug.downcase.gsub('-',' ').split.map { |word|
      word.gsub(/[^0-9A-Za-z]/, '')
    }.join('-')
    self.slug = slug

    # tag_word_array = []
    # self.name.gsub('-',' ').split.each do |word|
    #   _word = word.gsub(/[^0-9A-Za-z]/, '')
    #   unless _word == _word.capitalize
    #     _word.downcase!
    #   end
    #   tag_word_array << _word
    # end
    # _name = tag_word_array.join('-')

    _name = self.name.gsub('-',' ').split.map { |word|
      word.gsub(/[^0-9A-Za-z]/, '')
    }.join('-')

    self.name = _name
  end
end
