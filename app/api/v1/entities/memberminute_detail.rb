# frozen_string_literal: true
module V1
  module Entities
    class MemberminuteDetail < Grape::Entity
      expose :id, :title, :description

      expose :memberminute_sections, as: :member_minute, :using => V1::Entities::MemberminuteSection do |instance, _options|
        instance.memberminute_sections.member_minute
      end
      expose :memberminute_sections, as: :issue, :using => V1::Entities::MemberminuteSection do |instance, _options|
        instance.memberminute_sections.savvy_time
      end
    end
  end
end