#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

require "rake/clean"

namespace :assets do
  # TODO: update to use public repository URL once we open-source it
  git_url     = "git@github.com:LyricaMcT/dashboard-ui.git"
  module_root = File.join("assets", "dashboard-ui")
  source_root = File.join(module_root, "build")
  assets_root = File.join("public", "assets")
  filenames   = %w(dashboard.min.css dashboard.min.js sprite.png)

  source_files = filenames.collect { |filename|
    File.join(source_root, filename)
  }

  assets_files = filenames.collect { |filename|
    File.join(assets_root, filename)
  }

  CLOBBER.concat source_files

  directory assets_root

  source_files.each do |source|
    file source => [:gulp]
  end

  assets_files.zip(source_files).each do |artifact, source|
    file artifact => [assets_root, source] do
      cp source, artifact
    end
  end

  desc "Build minified assets and copy them into public"
  task :build => assets_files

  task :gulp => [:packages] do
    Dir.chdir(module_root) do
      sh "gulp --production"
    end
  end

  task :packages => [:clone] do
    checkpoint = File.join("assets", ".installed")

    unless File.exists?(checkpoint)
      Dir.chdir(module_root) do
        node_bin = File.join(Dir.pwd, "node_modules", ".bin")

        # add node's .bin to PATH
        old_path, ENV["PATH"] = ENV["PATH"], ENV["PATH"] + File::PATH_SEPARATOR + node_bin

        sh "npm install bower gulp"
        sh "npm install"
        sh "bower install"

        old_path and
          ENV["PATH"] = old_path
      end

      touch checkpoint
    end
  end

  task :clone do
    unless File.exists?(File.join(module_root, "gulpfile.js"))
      mkdir_p File.dirname(module_root)
      sh "git clone --branch=master #{git_url} #{module_root}"
    end
  end
end
