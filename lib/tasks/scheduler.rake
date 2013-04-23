desc 'This task is called by the Heroku scheduler add-on'
task :process_orders => :environment do
  ProcessOrders.new.run
end