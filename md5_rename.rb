# TODO: Add options to:
# => prepend md5 digest to already existing filename
# => append md5 digest to already existing filename
# => overwrite existing filename with md5 digest
# => set default renaming strategy to prepend
# make generating md5 files in each directory the default script action
# option to delete all md5 breadcrumbs in each directory
# option to find all duplicate files in directories
# should also show directories that have more than one duplicate in common
# have an automatic delete mode that deletes duplicate by keeping the oldest and deleting the newest ones
# should show directories with duplicates sorted by number of duplicates
# should have an interactive mode with a help menu that will allow the user to choose which group of duplicates to delete
# should have an md5_ignore.txt with a list of files that should not be digested
# a strategy or other pattern for specific file types, so files like mp3 can be digested without the tag information ?

# a list of deleteable files, files that can be deleted if they are the only ones in that folder (thereby making the folder deletable too)
require 'digest/md5'

class Md5Rename
  def self.rename_files(folder)
    raise "Missing param: folder" if folder.nil?

    puts "Processing #{folder}"

    Dir[folder + "/*"].each do |file|
      if File.directory? file
        rename_files(File.expand_path(File.join(folder, file)))
      else
        rename_file file 
      end
    end
  end

  def self.rename_file(file)
    if should_rename? file 
      digest = Digest::MD5.new.hexdigest(File.read(file))
      new_filename = File.join(File.dirname(file), digest + File.extname(file))
      File.rename file, new_filename
    end
  end

  def new_filename(file)

  end
  
  def self.should_rename?(file)
    extensions.include?(File.extname(file))
  end

  def self.extensions
    [".jpg"]
  end
end

begin
  Md5Rename.rename_files(ARGV[0])
end