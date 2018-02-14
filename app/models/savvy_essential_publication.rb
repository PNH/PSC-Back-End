class SavvyEssentialPublication < ActiveRecord::Base
  belongs_to :savvy_essential
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  belongs_to :action_plan, class_name: 'Rich::RichFile', foreign_key: 'rich_attachment_id'
  has_many :savvy_essential_publication_sections, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :publication_date, :rich_file_id, presence: true

  scope :latest_issue_savvy, -> (current_date) {
    where("publication_date <= ? AND status = true", current_date.end_of_month).order("publication_date DESC").first
  }

  validate :has_only_one_publication_per_month
  def has_only_one_publication_per_month
    return if publication_date.nil?
    savvy_essential_id = self.savvy_essential.id
    published = !SavvyEssential.find(savvy_essential_id).savvy_essential_publications.find { |p|
      next if (!p.id.nil?) && (p.id == id)
      (p.publication_date.year == publication_date.year) && (p.publication_date.month == publication_date.month)
    }.blank?
    if published
      errors.add(:publication_date, "already published for #{publication_date.strftime("%B %Y")}")
    end
  end

  validate :additional_content_as_an_url
  def additional_content_as_an_url
    return if additional_content.empty?
    url = URI.parse(additional_content)
    unless %w( http https ).include?(url.scheme)
      errors.add(:additional_content, "invalid url")
    end
  end
end
