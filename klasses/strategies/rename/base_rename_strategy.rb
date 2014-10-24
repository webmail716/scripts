class BaseRenameStrategy
  def already_renamed?(file)
    file.eql? new_name file
  end

  def extensions
    [".jpg", ".png"]
  end  

  def should_rename?(file)
    extensions.include?(File.extname(file)) && is_cryptic?(file) && !already_renamed?(file)
  end

  def is_cryptic?(file)
    # pattern is digits_digits_digits_letter.extension
    file =~ /\d+_\d+_\d+_[a-zA-Z]/
  end

  def rename_file(file)
    if should_rename? file 
      new_filename = new_name file
      puts "Renaming #{file} to #{new_filename}"
      File.rename file, new_filename
      #save the digest under the new name ?
    end
  end

end