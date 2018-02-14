class HorseHealth < ActiveRecord::Base
  has_one :wall, as: :wallposting
  belongs_to :horse

  enum health_type: [:farrier, :veterinary, :holistic]
  enum visit_type: {
    corrective: 0,
    shoeing: 1,
    trim: 2,
    colic: 4,
    dental: 5,
    'de-worming'.to_sym => 6,
    emergency: 7,
    exam: 8,
    'physical therapy'.to_sym => 9,
    'routine checkup'.to_sym => 10,
    surgery: 11,
    vaccination: 12,
    "accupuncture/acupressure".to_sym => 13,
    Chiropractic: 14,
    "essential oils".to_sym => 15,
    herbal: 16,
    "massage/body work".to_sym => 17,
    "red light therapy".to_sym => 18,
    "other (please specify in notes)".to_sym => 100
  }

  # def self.visit_type(type)
  #   visit_types = nil
  #   case type
  #   when types[:corrective]
  #     visit_types = [:corrective => 0, :shoeing => 1, :trim => 2, "other (please specify)".to_sym => 3]
  #   when types[:veterinary]
  #     visit_types = [:colic, :dental, 'de-wormin'.to_sym, :emergency, :exam, 'physical therapy'.to_sym, 'routine checkup'.to_sym, :surgery, :vaccination, "other (please specify)".to_sym]
  #   when types[:holistic]
  #     visit_types = ["accupuncture/acupressure".to_sym, :chiropracic, "essential oils".to_sym, :herbal, "massage/body work".to_sym, "red light therapy".to_sym, "other (please specify)".to_sym]
  #   end
  #
  #   return visit_types
  # end

  def self.get_visit_type
    visit_types = {
      :farrier => {:id =>0, :types => [:corrective => 0, :shoeing => 1, :trim => 2, "other (please specify in notes)".to_sym => 100]},
      :veterinary => {:id =>1, :types => [:colic => 4, :dental => 5, 'de-worming'.to_sym => 6, :emergency => 7, :exam => 8, 'physical therapy'.to_sym => 9, 'routine checkup'.to_sym => 10, :surgery => 11, :vaccination => 12, "other (please specify in notes)".to_sym => 100]},
      :holistic => {:id =>2, :types => ["accupuncture/acupressure".to_sym => 13, :chiropractic => 14, "essential oils".to_sym => 15, :herbal => 16, "massage/body work".to_sym => 17, "red light therapy".to_sym => 18, "other (please specify in notes)".to_sym => 100]}
    }
    return visit_types
  end
end
