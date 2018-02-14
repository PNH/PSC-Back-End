# frozen_string_literal: true
class User < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:first_name, :last_name], :if => :searchable_user?, :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  def searchable_user?
    role != "member" || deleted_at != nil ? false : true;
  end

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  include DeviseTokenAuth::Concerns::User

  belongs_to :home_address, class_name: 'Address', foreign_key: :home_address_id
  belongs_to :billing_address, class_name: 'Address', foreign_key: :billing_address_id
  belongs_to :profile_picture, class_name: 'Rich::RichFile'
  belongs_to :level
  belongs_to :currency
  has_many :chat_bubbles, dependent: :destroy
  has_many :testimonials, dependent: :destroy
  has_many :horses, dependent: :destroy
  has_many :membership_details, dependent: :destroy
  has_many :subscrpt_credit_cards, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :group, through: :group_moderators
  has_many :group_moderators, :dependent => :destroy
  has_many :group, through: :group_members
  has_many :group_members, :dependent => :destroy

  has_many :forum_topics
  has_many :sub_forums, dependent: :destroy
  has_many :forums
  has_many :posts, dependent: :destroy
  has_many :forum, through: :forum_members
  has_many :forum_members, :dependent => :destroy
  has_many :forum, through: :forum_moderators
  has_many :forum_moderators, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_many :walls, :dependent => :destroy
  has_many :user_equestrain_interests, :dependent => :destroy
  has_many :instructors, class_name: 'UserInstructor', :dependent => :destroy
  # has_many :user_instructors


  # where I request to connect (i connect with him/her)
  has_many :connected_with,  foreign_key: :user_one_id, class_name: 'UserConnection', :dependent => :destroy
  # where Other person request to connect (he/she connect with me)
  has_many :connected_to,  foreign_key: :user_two_id, class_name: 'UserConnection', :dependent => :destroy

  accepts_nested_attributes_for :home_address
  accepts_nested_attributes_for :billing_address

  enum role: [:admin, :super_admin, :guest, :member, :deleted]
  enum gender: [:male, :female]
  enum relationship: [
    'Single (18+)'.to_sym,
    :not_in_a_relationship,
    'In a relationship (18+)'.to_sym,
    :married,
    :widowed,
    :separated,
    :divorced,
    :unknown
  ]
  enum equestrain_style: [:english, :western]

  enum humanity: ['Unknown'.to_sym,
                  'Left Brain Extrovert (LBE)'.to_sym,
                #  'Left Brain Extrovert (not LBE)'.to_sym,
                 'Left Brain Extrovert Axis Point'.to_sym,
                 'Left Brain Extrovert/Introvert Cusp (LBE/LBI)'.to_sym,
                 'Left Brain/Right Brain Extrovert Cusp (LBE/RBE)'.to_sym,
                 'Left Brain Introvert (LBI)'.to_sym,
                #  'Left Brain Introvert (not LBI)'.to_sym,
                 'Left Brain Introvert Axis Point'.to_sym,
                 'Left Brain Introvert/Extrovert Cusp (LBI/LBE)'.to_sym,
                 'Left Brain/Right Brain Introvert Cusp (LBI/RBI)'.to_sym,
                 'Right Brain Extrovert (RBE)'.to_sym,
                #  'Right Brain Extrovert (not RBE)'.to_sym,
                 'Right Brain Extrovert Axis Point'.to_sym,
                 'Right Brain Extrovert/Introvert Cusp (RBE/RBI)'.to_sym,
                 'Right Brain Extrovert/Left Brain Extrovert Cusp (RBE/LBE)'.to_sym,
                 'Right Brain Introvert (RBI)'.to_sym,
                #  'Right Brain Introvert (not RBI)'.to_sym,
                 'Right Brain Introvert Axis Point'.to_sym,
                 'Right Brain Introvert/Extrovert Cusp (RBI/RBE)'.to_sym,
                 'Right Brain Introvert/Left Brain Introvert Cusp (RBI/LBI)'.to_sym]

  validates :role, presence: true
  attr_accessor :password_text, :credit_card, :referralId, :referralCode, :current_password, :update

  after_initialize do
    self.role = 'guest' if new_record? && self.role.nil?
    self.billing_address ||= Address.new
    self.home_address ||= Address.new
  end

  after_save :update_netsuite
  before_save :sync_netsuite

  def name
    "#{first_name} #{last_name}"
  end

  def get_country
    home_address.present? ? home_address.country : nil
  end

  def get_subscription_status
    subscriptions.last.nil? ? false : subscriptions.last.is_active
  end

  def get_temp_horse
    horses.find_or_initialize_by(name: '')
  end

  def profilePic
    if profile_picture.nil?
      Rails.application.config.s3_source_path + 'default/UserDefault.png'
    else
      profile_picture.rich_file.url('thumbl')
    end
  end

  def membership_level
    membership_details.last.membership_type.level.to_s  if membership_details.present?
  end

  def is_active?
    true
  end

  def unread_messages_count
    Message.joins(:message_recipient).where('message_recipients.user_id = ?',self.id).where(status: false).count
  end
  #view point of current user accessing other user's profile
  def unread_sent_messages_count_to_current_user(recipient)
    Message.joins(:message_recipient).where('message_recipients.user_id = ?',recipient.id).where('messages.user_id = ?',self.id).where(status: false).count
  end

  def wall_privacy
    ps = ::Privacysetting.where('user_id=? and privacy_type=?', self.id,Privacysetting.privacytypes[:wallsetting])
    ps.empty? ? ::Privacysetting.statuses[:privacy_public] : ::Privacysetting.statuses[ps.first.status]
  end

  def wall_posts_count
    self.walls.count
  end

  def connections_count
    self.active_connections.count
  end

  def active_connections
    UserConnection.where("connection_status=? AND user_one_id=? OR connection_status=? AND user_two_id=?", UserConnection.connection_statuses[:accepted], self.id, UserConnection.connection_statuses[:accepted], self.id)
  end

  def pending_connections
    self.connected_to.where(connection_status: UserConnection.connection_statuses[:pending])
  end

  def pending_connection_requests
    self.connected_with.where(connection_status: UserConnection.connection_statuses[:pending])
  end

  def blocked_connections
    self.connected_with.where(connection_status: UserConnection.connection_statuses[:blocked])
  end

  def declined_connections
    self.connected_with.where(connection_status: UserConnection.connection_statuses[:declined])
  end

  def connection_status(user_id)
    UserConnection.where("user_one_id=(?) AND user_two_id=(?) OR user_one_id=(?) AND user_two_id=(?)", self.id, user_id, user_id, self.id)
  end

  def is_connected(user_id)
    !UserConnection.where("user_one_id=(?) AND user_two_id=(?) AND connection_status=? OR user_one_id=(?) AND user_two_id=(?) AND connection_status=?", self.id, user_id, UserConnection.connection_statuses[:accepted], user_id, self.id, UserConnection.connection_statuses[:accepted]).empty?
  end

  private

  def update_netsuite
    return true unless member?
    # credit_card.save
    # NetsuiteCreateMemberJob.perform_later(self, credit_card, password_text, referralId, referralCode)
  end

  def sync_netsuite
    return true unless member?
    unless new_record?
      # NetsuiteUpdateAddressJob.perform_later(id) if billing_address_id_changed?
      # NetsuiteUpdateEmailJob.perform_later(id) if email_changed?
      # NetsuiteUpdatePasswordJob.perform_later(id, password_text) unless password_text.blank?
    end
  end

end
