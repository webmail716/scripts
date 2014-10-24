require 'yaml'
require 'pry'

class Metadata
  include Singleton

  def initialize
    @file_metadata = Hash.new
    @cached = Hash.new  #a copy of metadata that has not been persisted to disk
    @yaml = Hash.new
  end

  #return the metadata for the file
  def get(file)
    binding.pry
    #return the values from cached first
    @cached[file] || 
    @file_metadata[file] || 
    read_metadata_from_yaml(file) || 
    cache(file, read_metadata_from_disk(file)) 
  end

  def set(file, metadata)
    @cached[file] = metadata
  end

  def persist
    #update the yaml files in memory with the correct metadata for each file
    copy_cached_to_yaml

    #now write those yaml files out to disk
    write_yaml_to_disk
  end

  def copy_cached_to_yaml
    @cached.each_pair do |file, metadata|
      yaml_filename = construct_yaml_filename(file)
      md5 = metadata[:md5]

      #theres a conflict if we already have an entry for this md5 and its filename is different than our current file
      conflict = @yaml[yaml_filename] && @yaml[yaml_filename][md5] && @yaml[yaml_filename][md5][:filepath] != file

      if conflict
        resolve_yaml_conflict yaml_filename, md5, metadata
      else
        @yaml[yaml_filename] ||= {} #init the hash for this yaml file if needed
        @yaml[yaml_filename][md5] = metadata
      end
    end
  end

  def resolve_yaml_conflict(yaml_filename, md5, new_metadata)
    #compare both ctimes, keep the file that is older
    old_metadata = @yaml[yaml_filename][md5]

    puts "Found dupe files: #{old_metadata[:filepath]}, #{new_metadata[:filepath]}"

    if new_metadata[:ctime] <= old_metadata[:ctime]
      #the file we just found is older than the one we already had in the yaml file
      @yaml[yaml_filename][md5] = new_metadata

      #delete the old file. it is a duplicate
      puts "Deleting old file: #{old_metadata[:filepath]}"
    else
      #delete the new file. it is a duplicate
      puts "Deleting file: #{new_metadata[:filepath]}"
      # File.delete new_metadata[:filepath]
    end
  end

  def write_yaml_to_disk
    @yaml.each_pair do |yaml_filename, content| 
      File.open(yaml_filename, "w") { |file| file.write content.to_yaml }
    end
  end

  def cache(file, metadata)
    @cached[file] = metadata
  end

  #when this instance is garbage collected, persist the remaining cached metadata to disk
  def close
    persist
  end

  # def file_renamed(old_filename, new_filename, new_metadata)
  #   old_yaml_file = construct_yaml_filename old_filename

  #   #remove metadata for that file from this yaml file
  #   @yaml[old_yaml_file].each_pair do |md5, metadata|
  #     if metadata[:filepath].eql? old_filename
  #       @yaml[old_yaml_file][md5] = nil #delete entry for this file in this yaml
  #       break
  #     end
  #   end

  #   #add metadata for this new file to this yaml file
  #   new_yaml_file = construct_yaml_filename new_filename
  #   @yaml[new_yaml_file][new_metadata[:md5]] = new_metadata
  # end

private

  def read_metadata_from_yaml(file)
    yaml_file = construct_yaml_filename file

    return nil unless File.exists?(yaml_file) && File.size(yaml_file) > 0

    unless yaml_in_memory? yaml_file
      read_yaml_into_memory(yaml_file)
    end

    @yaml[yaml_file].each_pair do |md5, metadata| 
      if metadata[:filepath].eql? file
        return metadata
      end
    end
  end

  def read_metadata_from_disk(file)
    {
      size: File.size(file),
      md5: Utils.get_md5(file),
      ctime: File.ctime(file),
      filepath: file
    }
  end

  def construct_yaml_filename(file)
    File.join File.dirname(file), "metadata.yml"
  end

  def yaml_in_memory?(yaml_file)
    @yaml.has_key?(yaml_file)
  end

  def read_yaml_into_memory(yaml_file)
    @yaml[yaml_file] = YAML.load(File.read(yaml_file))
  end

end