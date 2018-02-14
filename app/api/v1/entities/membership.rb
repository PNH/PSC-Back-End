# frozen_string_literal: true
module V1
  module Entities
    class Membership < Grape::Entity
      expose :id, :billing_frequency, :level, :tax, :benefits, :item_id, :benefit_title
      expose :bf_if do |instance|
        MembershipType.billing_frequencies[instance.billing_frequency]
      end
      expose :level_id do |instance|
        MembershipType.levels[instance.level]
      end
      expose :costs do |instance|
        costs = []
        mc_count = MembershipType.count
        instance.item_costs.each do |ic|
            if ic.currency.present? && ic.currency.title.present? 
              costs.push('title' => ic.currency.title,
                     'symbol' => ic.currency.symbol,
                     'country' => ic.currency.country,
                     'cost' => ic.cost,
                     'currencyId' => ic.currency.id)
          end
        end
        costs
      end
    end
  end
end
