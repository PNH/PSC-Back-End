# frozen_string_literal: true
ActiveAdmin.register_page 'Dashboard' do
  # menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }
  menu false

  content title: proc { I18n.t('active_admin.dashboard') } do
    # div class: 'blank_slate_container', id: 'dashboard_default_message' do
    #   span class: 'blank_slate' do
    #     span I18n.t('active_admin.dashboard_welcome.welcome')
    #     small I18n.t('active_admin.dashboard_welcome.call_to_action')
    #   end
    # end

    columns do
      column do
        panel 'Users' do
          div class: 'dashboard-center' do
            span class: 'center-text' do
              User.where(role: 3).where.not(entity_id: -1).count
            end
          end
        end
      end
      column do
        panel 'Events' do
          div class: 'dashboard-center' do
            span class: 'center-text' do
              Event.open_events.count
            end
          end
        end
      end
      column do
        panel 'Blogs' do
          div class: 'dashboard-center' do
            span class: 'center-text' do
              BlogPost.where(blog_id: 1, status: 1).count
            end
          end
        end
      end
      column do
        panel 'Groups' do
          div class: 'dashboard-center' do
            span class: 'center-text' do
              Group.where(status: true).count
            end
          end
        end
      end
      column do
        panel 'Forums' do
          div class: 'dashboard-center' do
            span class: 'center-text' do
              Forum.forums.count
            end
          end
        end
      end
    end

    columns do
      column do
        panel 'Most Recently Added Events' do
          table_for Event.recent_added_events(5) do
            column 'id', :id
            column('title') { |event| link_to event.title, edit_admin_event_path(event.id) }
            column('start date') { |event| event.start_date.strftime(I18n.t('date.formats.default')) }
            column('end date') { |event| event.end_date.strftime(I18n.t('date.formats.default')) }
            column('created at') { |event| event.created_at.strftime(I18n.t('date.formats.default')) }
          end
        end
      end
      column do
        panel 'Most Recently Added Blogs' do
          table_for BlogPost.enabled_recent_blog_posts(5) do
            column 'id', :id
            column('title') { |post| link_to post.title, edit_admin_blog_post_path(post.id) }
            column('created at') { |post| post.created_at.strftime(I18n.t('date.formats.default')) }
          end
        end
      end
      column do
        panel 'Most Recently Added Groups' do
          table_for Group.recent_groups(5) do
            column 'id', :id
            column('title') { |group| link_to group.title, edit_admin_group_path(group.id) }
            column 'privacy level', :privacy_level
            column('created at') { |group| group.created_at.strftime(I18n.t('date.formats.default')) }
          end
        end
      end
      column do
        panel 'Most Recently Added Forums' do
          table_for Forum.recent_forums(5) do
            column 'id', :id
            column('title') { |forum| link_to forum.title, edit_admin_forum_path(forum.id) }
            column('user') { |forum| link_to forum.user.name, edit_admin_user_path(forum.user.id) }
            column('created at') { |forum| forum.created_at.strftime(I18n.t('date.formats.default')) }
          end
        end
      end
    end

    # columns do
    #   column do
    #     panel 'Comments' do
    #       table_for Comment.recent_comments(5) do
    #         column 'id', :id
    #         column('message') { |comment| link_to comment.message, admin_comment_path(comment.id) }
    #         column('user') { |comment| link_to comment.user.name, edit_admin_user_path(comment.user.id) }
    #         column('created at') { |comment| comment.created_at.strftime(I18n.t('date.formats.default')) }
    #       end
    #     end
    #   end
    # end
  end
end
