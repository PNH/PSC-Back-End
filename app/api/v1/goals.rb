# frozen_string_literal: true
module V1
  class Goals < Grape::API
    prefix 'api'
    resource :goals do
      get do
        goals = Goal.where(status: true).order(id: :desc).limit(8)
        {
          status: 200,
          message: '',
          content: Entities::Goals.represent(goals)
        }
      end
    end

    namespace 'goals/:goal_id' do
      resource :issue_categories do
        get do
          issue_categories = IssueCategory.where(goal_id: params[:goal_id])
                                          .where(status: true)
          {
            status: 200,
            message: '',
            content: Entities::IssueCategory.represent(issue_categories)
          }
        end
      end

      resource :issues do
        get do
          issue_categories = IssueCategory.where(goal_id: params[:goal_id])
                                          .where(status: true)
          {
            status: 200,
            message: '',
            content: Entities::GoalsIssueTree.represent(issue_categories)
          }
        end
      end
    end

    namespace 'goals/:goal_id/issue_categories/:issue_category_id' do
      resource :issues do
        get do
          issues = Issue.where(issue_category_id: params[:issue_category_id])
          {
            status: 200,
            message: '',
            content: Entities::Issue.represent(issues)
          }
        end
      end
    end

    namespace 'goals/:goal_id' do
      resource :sample_lessons do
        get do
          lesson = Goal.find(params[:goal_id]).sample_lessons.order('RANDOM()').first
          {
            status: 200,
            message: '',
            content: Entities::LessonDetail.represent(lesson, current_user: current_user)
          }
        end
      end
    end
  end
end
