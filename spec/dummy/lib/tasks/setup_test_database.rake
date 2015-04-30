namespace :test do
  task :setup_database => :environment do |t, args|
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end
end