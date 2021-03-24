class ApplicationController < ActionController::Base

    before_action :set_locale
    before_action :authenticate_user!
    #al saltar la denegacion de acceso de CanCan se ejecuta una accion de "rescate" y se redirecciona al index
    rescue_from CanCan::AccessDenied do |exception|
        redirect_to root_path
    end
    
    def set_locale
        I18n.locale ='es'
    end
end