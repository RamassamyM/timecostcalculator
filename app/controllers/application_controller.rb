class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from BaseShipping::CSVError, with: :handle_csv_error

  private

  def handle_csv_error(exception)
    puts exception.message
    flash[:alert] = exception.message
    redirect_to(purchases_path)
  end

  def handle_program_error(exception)
    puts exception.message
    flash[:alert] = "Sorry, we have a technical error. Please contact your administrator."
    redirect_to(purchases_path)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(home_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^purchases$)|(^searches$)/
  end
end
