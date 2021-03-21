class SettingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user && user.admin? || false
  end

  def update?
    user && user.admin? || false
  end
end
