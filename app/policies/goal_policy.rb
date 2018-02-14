class GoalPolicy < ApplicationPolicy
  def update?
    user.super_admin?
  end

  def create?
    user.super_admin?
  end
end
