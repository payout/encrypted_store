namespace :test do
  ENV['RAIL_ENV'] = 'test'
  task :setup_database => ["db:create", "db:migrate"]
  task :setup => ['test:setup_database']
end