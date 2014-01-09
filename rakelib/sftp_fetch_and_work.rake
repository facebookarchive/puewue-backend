namespace :sftp do
  desc "Batch fetching and processing of CSV files"
  task :fetch_and_work => :environment do
    Rake::Task["sftp:fetch"].invoke
    Rake::Task["sftp:work"].invoke
  end
end
