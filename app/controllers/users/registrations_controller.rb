# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
   protected

   def after_sign_up_path_for(resource)
      study_logs_path
   end

   def update_resource(resource, params)
      resource.update_without_password(params)
    end

   def after_update_path_for(resource)
    users_profile_path(current_user.id)
  end
end
