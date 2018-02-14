# frozen_string_literal: true
module V1
  module Entities
    class MembershipDetail < Grape::Entity
      expose :id, :billing_frequency, :level, :tax, :cost
      expose :bf_id do |instance|
        MembershipType.billing_frequencies[instance.billing_frequency]
      end
      expose :level_id do |instance|        
        MembershipType.levels[instance.level]
      end
      expose :status do |instance|
        instance.user.get_subscription_status
      end
      expose :joined_date do |instance|
        instance.user.subscriptions.last.start_date if instance.user.subscriptions.last.present?
      end
      expose :membership_number do |instance|
        instance.user.subscriptions.last.present? ? instance.user.subscriptions.last.display_id : instance.user.id
      end
      expose :membershipTypeId do |instance|
        instance.membership_type.id
      end
    end
  end
end
