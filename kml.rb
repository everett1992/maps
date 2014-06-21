require 'nokogiri'
require 'bigdecimal'

class Kml
  include Magick
  attr_reader :images, :name

  def initialize(uri)
    doc = Nokogiri::XML(open(uri))

    @name = doc.search('kml Document name').text
    @images = doc.search('kml Document GroundOverlay').map do |go|
      KmlImage.new(
        uri: go.search('Icon href').text,
        north: go.search('LatLonBox north').text,
        south: go.search('LatLonBox south').text,
        east: go.search('LatLonBox east').text,
        west: go.search('LatLonBox west').text
      )
    end
  end

  ##
  # Returns a 2d array of images in their physical order.
  #
  # This might assume the lat/longs are in the northern hemisphere.
  def organize_images
    images.group_by(&:north).map{ |_, row| row.sort_by(&:east) }.reverse
  end

  ##
  # Returns the kml as a single image.
  def to_image
    map = ImageList.new
    map += organize_images.map do |row|
      ImageList.new(*row.map(&:uri)).append_horizontal
    end
    map.append_vertical
  end
end

class KmlImage
  attr_reader :uri, :north, :south, :east, :west

  def initialize(uri: uri, north: n, south: s, east: e, west: w)
    @uri = uri;
    @north = BigDecimal.new(north)
    @south = BigDecimal.new(south)
    @east  = BigDecimal.new(east)
    @west  = BigDecimal.new(west)
  end
end

class Magick::ImageList
  def append_horizontal
    append(false)
  end

  def append_vertical
    append(true)
  end
end
