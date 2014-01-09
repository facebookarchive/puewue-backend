namespace :db do
  desc "Reset database contents. Set force to 'yes' to confirm."
  task :reset, [:force] => :environment do |t, args|
    rack_env = ENV.fetch("RACK_ENV", "development")
    args.with_defaults(:force => (rack_env == "development"))

    if args.force
      Rake::Task['db:reset:tire'].invoke
    else
      abort "Error: you need to `force` to clear database in this environment."
    end
  end

  namespace :reset do
    task :tire => :environment do
      require "tire"

      puts "Resetting ElasticSearch index..."

      index = Tire.index "measurements"
      index.delete
    end
  end
end
