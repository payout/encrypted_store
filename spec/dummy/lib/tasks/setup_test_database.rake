namespace :test do
  task :setup_database => [:environment] do |t, args|
    system("rake db:create RAILS_ENV=test")
    system("rake db:migrate RAILS_ENV=test")
  end

  task :setup => [:environment] do |t, args|
    Rake::Task['test:setup_database'].invoke
  end
end