require_relative "../../utils.rb"
require_relative "base_rename_strategy.rb"

class DateMd5Strategy < BaseRenameStrategy

  def new_name(file)
    #our strategy is to rename the file to #{md5}.#{extension}
    digest = ::Utils.get_md5 file
    timestamp = File.ctime(file).strftime("%Y-%m-%d_%H-%M-%S")
    File.join(File.dirname(file), timestamp + "_" + digest + File.extname(file))
  end

  def should_rename?(file)
    extensions.include?(File.extname(file)) && !already_renamed?(file) && 
      (is_cryptic?(file) || is_md5?(file))
  end

  def is_md5?(file)
    md5 = Utils.get_md5 file
    File.basename(file, File.extname(file)).eql? md5
  end
end
