desc 'This task is called by the Heroku scheduler add-on'
task :hello_world => :environment do
  puts 'Hello world'
end