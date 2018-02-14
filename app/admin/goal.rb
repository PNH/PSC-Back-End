# frozen_string_literal: true
ActiveAdmin.register Goal do
  menu false

  filter :title_cont, label: 'By Goal Title'
  filter :status, label: 'By Status', collection: { 'Active' => true, 'Inactive' => false }

  permit_params :title, :status, :rich_file_id, goal_lesson_attributes: [:lesson_id]

  index do
    column :id
    column :title
    column('Status') { |medallion| medallion.status ? 'Active' : 'Inactive' }
    column('Issue Categories') do |goal|
      link_to goal.issue_categories.count, admin_goal_issue_categories_path(goal)
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :title, input_html: { maxlength: 130 }, hint: 'Max Length 130'
      f.input :rich_file_id, as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }, label: 'Background Image'
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
    end
    f.inputs do
      f.has_many :goal_lesson, heading: 'Goal Lesson', for: [:goal_lesson, GoalLesson.new], new_record: 'Add' do |cb|
        cb.input :lesson, label: 'Sample Lesson', as: :select2, collection:
          Lesson.sample.collect { |lsn|
            [lsn.title, lsn.id]
          }, include_blank: true
      end
      render 'sample_lessons'
    end
    f.actions
  end

  member_action :sample_lessons, method: [:delete] do
    lesson = Lesson.find(params[:lid])
    redirect_to :back if lesson.nil?
    goal = Goal.find(params[:id])
    goal.sample_lessons.destroy(lesson)
    redirect_to :back, notice: "Lesson #{lesson.title} removed successfully"
  end

  controller do
    rescue_from RuntimeError do |e|
      flash[:error] = e.message
      redirect_to :back
    end
  end
end
