# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

  # def authenticate_admin_user!
  #   authenticate_user!
  #   unless current_user.admin? || current_user.super_admin?
  #     flash[:alert] = 'Unauthorized Access!'
  #     redirect_to root_path
  #   end
  # end

  def authenticate_active_admin_user!
    authenticate_admin_user!
    unless current_admin_user.admin? || current_admin_user.super_admin?
      flash[:danger] = 'You are not authorized to access this resource!'
      redirect_to destroy_admin_user_session_path
    end
  end
end
