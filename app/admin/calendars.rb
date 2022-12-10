# frozen_string_literal: true

ActiveAdmin.register Calendar do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :sport_id, :name
  permit_params do
    permitted = [:name]
    permitted << :sport_id if params[:action] == "create"
    permitted
  end
  #
  # or
  #
  # permit_params do
  #   permitted = [:sport_id, :name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
