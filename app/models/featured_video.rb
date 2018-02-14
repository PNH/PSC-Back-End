class FeaturedVideo < LearngingLibrary
  scope :featured_video, -> { where(featured: true).where(status: true).videos }
end
