# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def new
      render inertia: "auth/sign_up"
    end

    def create
      build_resource(sign_up_params)

      if resource.save
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          redirect_to after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          redirect_to after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        redirect_to new_user_registration_path, inertia: { errors: resource.errors.to_hash(true) }
      end
    end
  end
end
