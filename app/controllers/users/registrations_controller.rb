# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

   protected

   def update_resource(resource, params)
    resource.update_without_password(params)
  end

     def configure_sign_up_params
       devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
     end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :profile_image,
      :profile_image_cache, :self_introduction, :systematizing_continuous_learning ])
    end

   def after_sign_up_path_for(resource)
      study_logs_path
   end

    def after_inactive_sign_up_path_for(resource)
      super(resource)
   end

   def after_update_path_for(resource)
    users_profile_path(current_user.id)
  end
end
