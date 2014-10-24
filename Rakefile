require_relative 'klasses/md5_rename.rb'
require_relative 'klasses/strategies/rename/md5_naming_strategy.rb'
require_relative 'klasses/strategies/rename/date_md5_strategy.rb'

desc "Rename files (recursively)"
task :rename do 
  starting_path = ENV['path']

  strategy = DateMd5Strategy.new # rename files by replacing the full name with the md5

  renamer = Md5Rename.new strategy
  renamer.rename_files starting_path
end