require 'rubygems'
require 'flickr'

$token = "#{File.expand_path('~')}/.ruphy-backupper/flickr-token.cfg"
$extensions = ["jpg", "png", "jpeg"]

class FlickrManager
  attr_reader :flickr
  
  def initialize root
    @flickr = Flickr.new($token, "6b68b90702411082818b8ca39919434a", "db8e5e4d8a08aa00")
    # puts flickr.auth.class
    unless @flickr.auth.token
      @flickr.auth.getFrob
      url = @flickr.auth.login_link
      puts "You must visit #{url} to authorize this application.  Press enter"+
                             " when you have done so. This is the only time you will have to do this."
      gets
      @flickr.auth.getToken
      @flickr.auth.cache_token
    end
    
    @root = root
  end
  
  def is_supported? filename
    a = filename.split('.')
    $extensions.each do |e|
      return true if e == a.last.downcase
    end
    return false
  end
  
  def photoset_exist? name
    @flickr.photosets.getList.each do |x|
      return true if x.title == name
    end
    return false
#     args = {}
#     args['user'] = @flickr.auth.token.user.nsid
#     args['privacy_filter'] = "5" #private pics
#     args['per_page'] = "2"
#     args['contentType'] = "1"
#     res = @flickr.call_method('flickr.photos.search', args)
#     last_pic = Flickr::PhotoList.from_xml(res, @flickr)[1].id #each do |x|
# #         puts x.id
# #   end
#     
#     @flickr.photosets.create name, last_pic
  end
  
  def upload f, photoset
    return if !is_supported?(f)
  
    id = @flickr.photos.upload.upload_file f, f, "", Array.new, false, false, false
    if photoset_exist? photoset
      set_id = get_photoset_id(photoset)
      @flickr.photosets.addPhoto set_id, id
    else
      @flickr.photosets.create photoset, id
    end
#     @flickr.photos.setPerms(id, false, false, false, "", "")
  end
  
  def get_photoset_id p
    a = nil
    @flickr.photosets.getList.each do |x|
      a = x.id if x.title == p
    end
    return a
  end
  
  def get_file_list name
    a = Array.new
    
    tot = @flickr.photosets.getInfo(get_photoset_id(name)).photo_count
    pg = 1
    nis = []
    while (tot > 0)
      args = { 'photoset_id' => get_photoset_id(name) }
      args['page'] = pg.to_s
      res = @flickr.call_method('flickr.photosets.getPhotos',args)
      nis += Flickr::PhotoSet.from_xml(res.root, @flickr)
      pg += 1
      tot -= 500
    end
    
    nis = nis.reject { |x| x == nil }
    
    nis.each do |x|
      a << x.title
    end
    return a
  end
  
  # Syncs a dir. path is relative
  def sync_dir dir
    # TODO: think of a better name scheme
    # maybe the title should include the relative path?
    calculated_photoset_name = "[ruphy-backup]#{dir}"
    Dir.chdir @root+'/'+dir

    if photoset_exist? calculated_photoset_name
      #sync
      flickr_list = get_file_list calculated_photoset_name
      local_list =  Dir["*"]
      remotely_missing = []
      locally_missing = []
      
      local_list.each do |f|
        remotely_missing << f unless flickr_list.include? f
      end
#       puts "remotely missing files: " + remotely_missing.join(',')
      
      remotely_missing.each do |f|
        upload f, calculated_photoset_name
      end
      
      
      flickr_list.each do |f|
        locally_missing << f unless local_list.include? f
      end
      puts "we're locally missing: " + locally_missing.join(', ')
      
      # TODO: really perform sync
      
    else
    # set not existing: just upload
      Dir["*"].each do |f|
        upload f, calculated_photoset_name
      end
    end
  end
  
end

f = FlickrManager.new "/home/ruphy/flickr"
# f.sync_dir "test"
puts f.is_supported? "waa.jpeg"

