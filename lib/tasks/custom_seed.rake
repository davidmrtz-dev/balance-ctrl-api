namespace :db do
  namespace :seed do
    Rails.root.glob('db/seeds/*.rb').each do |filename|
      task_name = File.basename(filename, '.rb').intern

      task task_name => :environment do
        load(filename)
      end
    end
  end
end
