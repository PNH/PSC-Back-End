RailsAdmin.config do |config|
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
  config.excluded_models = %w(Notification NotificationRecipient MembershipType HorseLesson)

  config.model 'Savvy' do
    label 'Savvy'
    label_plural 'Savvy'
  end

  config.model 'Memberminute' do
    label 'Savvy Time & Member Minutes'
    label_plural 'Savvy Time & Member Minutes'
  end

  config.model 'Role' do
    visible false
  end

  config.model 'Address' do
    visible false
  end

  config.model 'EventPrice' do
    visible false
  end

  config.model 'GroupRequest' do
    visible false
  end

  config.model 'MembershipDetail' do
    label 'Membership'
    label_plural 'Membership'
  end

  config.model 'EventUser' do
    visible false
  end

  config.model 'GroupMember' do
    visible false
  end

  config.model 'GroupModerator' do
    visible false
  end

  config.model 'LessonTool' do
    visible false
  end

  config.model 'TouchstoneResource' do
    visible false
  end

  config.model 'TouchstoneCategory' do
    label 'Touchstone'
    label_plural 'Touchstone'
  end

  config.model 'Touchstone' do
    label 'Publication'
    label_plural 'Publication'
  end

  config.model 'ChatBubble' do
    label 'Chat Bubble'
    label_plural 'Chat Bubble'
  end

  config.model 'TouchstoneSection' do
    label 'Touchstone Section'
    label_plural 'Touchstone Sections'
  end

  config.model 'EventCategory' do
    label 'Event Category'
    label_plural 'Event Category'
  end

  config.model 'LessonCategory' do
    label 'Lesson Category'
    label_plural 'Lesson Category'
  end

  config.model 'IssueCategory' do
    label 'Issue Category'
    label_plural 'Issue Category'
  end
end
