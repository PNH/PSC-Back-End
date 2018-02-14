ActiveAdmin.register Currency do
  menu false

  permit_params :title, :symbol, :country

  form do |f|
    inputs 'Currency Information' do
      f.input :title
      f.input :symbol
      f.input :country, include_blank: true, as: :select2, collection: ISO3166::Country.translations.collect{ |cnt|
        [cnt[1], cnt[0]]
      }
    end
    f.actions
  end
end
