require_relative "base_rename_strategy.rb"

class Md5NamingStrategy < BaseRenameStrategy

	def new_name(file)
    #our strategy is to rename the file to #{md5}.#{extension}
    digest = Utils.get_md5 file
    File.join(File.dirname(file), digest + File.extname(file))
	end
end