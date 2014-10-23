class Strategy::Rename::Md5NamingStrategy

	def new_name(file, md5)
    #our strategy is to rename the file to #{md5}.#{extension}
    File.join(File.dirname(file), md5 + File.extname(file))
	end

end