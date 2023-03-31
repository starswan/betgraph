# frozen_string_literal: true

ActiveAdmin.register FootballDivision do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :division_id, :football_data_code, :bbc_slug
  #
  # or
  #
  # permit_params do
  #   permitted = [:division_id, :football_data_code, :bbc_slug]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
