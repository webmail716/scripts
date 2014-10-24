require 'digest/md5'

class Utils
  @@digests = Hash.new

  def self.get_md5(file)
    #memoize the digests for each file so we don't have to recalculate them multiple times
    @@digests[file] || (@@digests[file] = Digest::MD5.new.hexdigest(File.read(file)))
  end
end