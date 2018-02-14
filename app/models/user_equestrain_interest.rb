class UserEquestrainInterest < ActiveRecord::Base
  self.table_name = 'user_equestrain_interest_mappings'

  belongs_to :user

  enum equestrain_interest: [
    :barrel_racing,
    :calf_roping,
    :camp_drafting,
    :cross_country,
    :cutting,
    :dressage,
    :endurance,
    :equitation,
    :eventing,
    :gymkhana,
    :horse_agility,
    :hunter,
    :instructor,
    :just_starting_out,
    :leisure,
    :mounted_shooting,
    :polo,
    :racing,
    :reined_cow_horse,
    :reining,
    :roping,
    :show_jumping,
    :sport,
    :team_penning,
    :team_roping,
    'trail_riding / hacking_out'.to_sym,
    :trec,
    :western_pleasure,
    :breeding,
    :camping,
    :colt_starting,
    :competitive_trail_riding,
    :driving,
    :extreme_cowboy_race,
    :farrier,
    :foal_handling,
    :liberty,
    :parelli_games_tournaments,
    :performances,
    :savvy_circles,
    :therapeutic_riding_programs,
    :vaulting,
    :veterinarian,
    :youth_programs
  ]

  # stupid, do something else
  def self.equestrain_interest_list
    list = Hash.new
    remove_items = ['calf_roping', 'camp_drafting', 'horse_agility', 'instructor', 'just_starting_out', 'sport', 'trec']
    sorted_list = equestrain_interests.sort_by { |word| word }
    sorted_list.reject! { |word| remove_items.include?(word[0]) }
    sorted_list.each { |eq| list.merge!(Hash[*eq]) }
    list
  end
end
