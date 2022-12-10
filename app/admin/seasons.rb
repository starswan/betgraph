# frozen_string_literal: true

ActiveAdmin.register Season do
  index do
    # id_column
    column :name
    column :startdate
    column :online
    column :calendar
    actions
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :startdate, :online, :calendar_id
  permit_params :name, :startdate, :online
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :startdate, :online, :calendar_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
