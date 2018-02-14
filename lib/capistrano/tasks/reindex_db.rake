namespace :parelli do

  # cap test parelli:reindex_db
  desc 'Database index fixing task'
  task :reindex_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, "parelli:reindex_db"
        end
      end
    end
  end

  # cap test parelli:pg_search_resync
  desc 'Parelli Full Search re-sync task'
  task :pg_search_resync do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, "parelli:pg_search_resync"
        end
      end
    end
  end
end
