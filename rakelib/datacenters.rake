desc "Populate with default datacenters"
task :datacenters do
  require "power/datacenter"

  Power::Datacenter.from_file("config/datacenters.yml")
end
