namespace :parelli do
  desc 'Rake task to re-sync the database indexng'
  task :reindex_db => :environment do
    count = 0
    ActiveRecord::Base.connection.tables.each do |t|
      print "indexing: #{t}\n"
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
      count += 1
    end
    print "Re-Sync completed - #{count} tables re-indexed\n"
  end

  desc 'Rake task to re-sync pg_search_documents table for full search'
  task :pg_search_resync => :environment do
    print "Re-Sync User Entity\n"
    PgSearch::Multisearch.rebuild(User)
    print "Re-Sync Event Entity\n"
    PgSearch::Multisearch.rebuild(Event)
    print "Re-Sync Group Entity\n"
    PgSearch::Multisearch.rebuild(Group)
    print "Re-Sync Lesson Entity\n"
    PgSearch::Multisearch.rebuild(Lesson)
    print "Re-Sync LearngingLibrary Entity\n"
    PgSearch::Multisearch.rebuild(LearngingLibrary)
    # print "Re-Sync Forums Entity"
    # PgSearch::Multisearch.rebuild(Forum, false)
    print "Re-Sync ForumTopic Entity\n"
    PgSearch::Multisearch.rebuild(ForumTopic)
    print "Re-Sync BlogPost Entity\n"
    PgSearch::Multisearch.rebuild(BlogPost)
  end

  desc 'Rake task to refresh missing styles'
  task :refresh_image_assets => :environment do
    all_images = Rich::RichFile.where("id > ?",13199).where(simplified_type: 'image')

    puts 'start refresh..'
    image_count = all_images.count
    process_count = 0
    puts "image count #{image_count}"

    all_images.each do |image|
      image.rich_file.reprocess!
      percentage = (++process_count / image_count) * 100.0
      print "#{percentage}% -- #{image.id}: #{image.rich_file_file_name} \n"
    end
    puts 'end refresh..'
  end

end
