#
# User.create!(
#   role: User.roles[:super_admin],
#   first_name: 'admin', last_name: 'admin',
#   email: Rails.application.secrets.admin_email,
#   password: Rails.application.secrets.admin_password,
#   password_confirmation: Rails.application.secrets.admin_password,
#   birthday: '1991-08-05'
# )
#
# Level.create!([
#                 { title: 'Level 1', color: '#ff000' },
#                 { title: 'Level 2', color: '#ff000' },
#                 { title: 'Level 3', color: '#ff000' },
#                 { title: 'Level 4', color: '#ff000' }
#               ])
#
# Savvy.create!([
#                 {
#                   title: 'On Line',
#                   level: Level.find_by(title: 'Level 1')
#                 },
#                 {
#                   title: 'On Line',
#                   level: Level.find_by(title: 'Level 2')
#                 },
#                 {
#                   title: 'Liberty',
#                   level: Level.find_by(title: 'Level 2')
#                 },
#                 {
#                   title: 'FreeStyle',
#                   level: Level.find_by(title: 'Level 2')
#                 },
#                 {
#                   title: 'On Line',
#                   level: Level.find_by(title: 'Level 3')
#                 },
#                 {
#                   title: 'Liberty',
#                   level: Level.find_by(title: 'Level 3')
#                 },
#                 {
#                   title: 'FreeStyle',
#                   level: Level.find_by(title: 'Level 3')
#                 },
#                 {
#                   title: 'Finesse',
#                   level: Level.find_by(title: 'Level 3')
#                 },
#                 {
#                   title: 'On Line',
#                   level: Level.find_by(title: 'Level 4')
#                 },
#                 {
#                   title: 'Liberty',
#                   level: Level.find_by(title: 'Level 4')
#                 },
#                 {
#                   title: 'FreeStyle',
#                   level: Level.find_by(title: 'Level 4')
#                 },
#                 {
#                   title: 'Finesse',
#                   level: Level.find_by(title: 'Level 4')
#                 }
#               ])
#
# scope = Settings::Scope.create!(title: 'Main')
# scope.settings.create!([
#                          { slug: 'homepage_video', title: 'Home Page Video', data_type: 'rich_file', input_type: 'video' },
#                          { slug: 'site_title', title: 'Site Title', data_type: 'string', input_type: 'input' },
#                          { slug: 'admin_name', title: 'Admin Name', data_type: 'string', input_type: 'input' },
#                          { slug: 'admin_email', title: 'Admin Email', data_type: 'string', input_type: 'input' },
#                          { slug: 'facebook', title: 'Facebook', data_type: 'string', input_type: 'input' },
#                          { slug: 'twitter', title: 'Twitter', data_type: 'string', input_type: 'input' },
#                          { slug: 'linkedin', title: 'Linkedin', data_type: 'string', input_type: 'input' },
#                          { slug: 'maintenance_mode', title: 'Maintenance Mode', data_type: 'boolean', input_type: 'radio' },
#                        ])
#

# Currency.delete_all
# puts 'Creating Currencies:'
# Currency.create!([
#                    { title: 'USD', symbol: '$' },
#                    { title: 'GBP', symbol: '£' },
#                    { title: 'EUR', symbol: '€' },
#                    { title: 'AUD', symbol: '$' },
#                    { title: 'CAD', symbol: '$' }
#                  ])
# puts "#{Currency.count} currenties"

# default savvy essential(1st category)
SavvyEssential.find_or_initialize_by(id: 1).update_attributes(title: 'Savvy Essentials', status: true)
