class AddRowToContentBlockTestimonialBackground < ActiveRecord::Migration
  def change
    content_block = ContentBlock.new title: "Testimonial Background", slug: "testimonial_background"
    _ext_block = ContentBlock.find_by(slug: content_block.slug)
    if _ext_block.nil?
      content_block.save
    end
  end
end
