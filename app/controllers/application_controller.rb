class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include ChallongeapisHelper
  include ParticipantsHelper
  include CharactersHelper
end
