# frozen_string_literal: true

ActiveAdmin.register FootballDivision do
  config.sort_order = "updated_at_desc"

  index do
    selectable_column
    column :division
    column :football_data_code
    column :bbc_slug
    column :rapid_api_country
    column :rapid_api_name
    actions
  end

  permit_params :division_id, :football_data_code, :bbc_slug, :rapid_api_name, :rapid_api_country

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :division
      f.input :football_data_code
      f.input :bbc_slug
      f.input :rapid_api_country, as: :string
      f.input :rapid_api_name
    end
    f.actions
  end
end
