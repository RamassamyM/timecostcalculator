class PurchasePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end

    def index?
      return true
    end

    def new?
      return true
    end

    def create?
      return true
    end
  end
end
