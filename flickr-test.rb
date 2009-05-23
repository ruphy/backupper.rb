require 'rubygems'
require 'flickr'
require 'sync/base'

class Set
  attr_accessor :title, :id, :description
end

class Collection
  attr_accessor :title, :id, :sets, :collections,
                :icon_large, :icon_small, :description
  def initialize
    @sets = Array.new
    @collections = Array.new
  end
  
  def add_set set
    @sets << set
  end
  
  def add_collection collection
    @collections << collection
  end
end

def parse_collection e
  c = Collection.new
  e.elements.each("collection") do |nested_e|
    c.add_collection parse_collection nested_e
  end
  e.elements.each("set") do |s|
    set = Set.new
    set.title = s.attributes['title']
    set.id = s.attributes['id']
    set.description = s.attributes['description']
    c.add_set set
  end
  c.title = e.attributes['title']
  c.id = e.attributes['id']
  c.icon_large = e.attributes['icon_large']
  c.icon_small = e.attributes['icon_small']
  c.description = e.attributes['description']
  return c
end

# f = FlickrManager.new
# response = f.flickr.call_method "flickr.collections.getTree"

def get_collections xml
  collections = Array.new
  xml.root.elements.each("collection") do |x|
    collections << parse_collection(x)
  end
  return collections
end

def test
  get_collections(response).each do |w|
    w.collections.each {|x| puts x.title}
    w.sets.each {|x| puts x.title }
  end
end


class SyncManager
  def initialize
  end
  
end


