require_relative "../../utils.rb"
require_relative "../../metadata.rb"
require_relative "base_rename_strategy.rb"

class DateMd5Strategy < BaseRenameStrategy
  REGEXS = [
    /\d+-\d+-\d+_\d+\.\d+\.\d+_*/
  ]
  def new_name(file)
    #our strategy is to rename the file to #{md5}.#{extension}
    metadata = ::Metadata.instance.get(file)
    digest = metadata[:md5]
    puts "metadata = #{metadata}"
    timestamp = metadata[:ctime].strftime("%Y-%m-%d_%H.%M.%S")
    File.join(File.dirname(file), timestamp + "_" + digest + File.extname(file))
  end

  def should_rename?(file)
    extensions.include?(File.extname(file)) && !already_renamed?(file) && 
      (is_cryptic?(file) || is_md5?(file) || matches_regexs?(file))
  end

  def is_md5?(file)
    metadata = ::Metadata.instance.get(file)
    File.basename(file, File.extname(file)).eql? metadata[:md5]
  end

  def matches_regexs?(file)
    REGEXS.each do |r|
      return true if r.match(file)
    end
  end
end
