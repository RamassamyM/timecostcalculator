class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Errno::ENOENT, with: :file_not_found
  rescue_from Errno::EACCES, with: :file_permission_not_allowed

  private

  def file_not_found
    flash[:alert] = "The CSV file was not found. Contact your administrator or check the file."
    redirect_to(home_path)
  end

  def file_permission_not_allowed
    flash[:alert] = "We cannot acces to the csv file because of permissions problems. Contact your administrator."
    redirect_to(home_path)
  end

  def parsing_error
    flash[:alert] = "Sorry, we had a problem while trying to get the data from the CSV. Contact your administrator."
    redirect_to(home_path)
  end

  def program_error
    flash[:alert] = "Sorry, we have a technical problem. Please contact your administrator then the technical support."
    redirect_to(home_path)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(home_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^purchases$)|(^searches$)/
  end
end
