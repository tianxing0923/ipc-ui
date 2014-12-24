require 'fileutils'

def kill_rails
  return unless File.file?('tmp/pids/server.pid')
  pid = IO.read('tmp/pids/server.pid')
  system("kill -9 #{pid}")
end


desc "build app"
task build: :environment do
  kill_rails
  system('rm -rf public/static/')
  system('rails s -e production -p 4567 -d')


  sleep 5
  
  puts 'package js/css files'
  system('rake assets:precompile RAILS_ENV=production')
  
  puts "package home/index.html"
  FileUtils.mkdir_p 'public/static/home'
  system("curl http://127.0.0.1:4567/home -o public/static/home/index.html")

  puts "package settings/index.html"
  FileUtils.mkdir_p 'public/static/settings'
  system("curl http://127.0.0.1:4567/settings -o public/static/settings/index.html")

  puts "package login/index.html"
  FileUtils.mkdir_p 'public/static/login'
  system("curl http://127.0.0.1:4567/login -o public/static/login/index.html")

  puts "package system/information/index.html"
  FileUtils.mkdir_p 'public/static/system/information'
  system("curl http://127.0.0.1:4567/system/information -o public/static/system/information/index.html")
  
  system('cp -r public/assets public/static/')
  system('rm public/static/assets/*.gz')

  # puts "package system/log/index.html"
  # FileUtils.mkdir_p 'public/static/system/information'
  # system("curl http://127.0.0.1:4567/system/log -o public/static/system/log/index.html")

  kill_rails
end
