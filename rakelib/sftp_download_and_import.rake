namespace :sftp do
  desc "Batch download and processing of CSV files (from: csv)"
  task :download_and_import => :environment do
    Rake::Task["sftp:download"].invoke
    Rake::Task["db:import"].invoke
  end
end
