class Privacysetting < ActiveRecord::Base
  belongs_to :user
  enum privacytype: [:wallsetting, :forumsetting, :groupsetting]
  enum status: [:privacy_private, :privacy_public, :privacy_connected]
end
