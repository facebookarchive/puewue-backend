case environment
when "staging"
  # fetch CSV and keep in csv/ directory
  task = "sftp:download_and_import"

when "production"
  # fetch CSV and store in Redis
  task = "sftp:fetch_and_work"
end

every 10.minutes do
  rake task
end
