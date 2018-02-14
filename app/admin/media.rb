ActiveAdmin.register_page 'Media' do
  menu false

  content do
    render 'medialib', host: request.host
  end
end
