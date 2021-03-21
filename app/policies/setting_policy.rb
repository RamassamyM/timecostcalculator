class SettingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end

    def index?
      record.user.admin == true
    end

  end
end
