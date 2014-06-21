require 'nokogiri'
require 'bigdecimal'

class Kml
  include Magick
  attr_reader :images, :name

  def initialize(uri)
    @uri = uri

    doc = Nokogiri::XML(open(uri))

    @name = doc.search('kml Document name').text
    @images = doc.search('kml Document GroundOverlay').map do |go|
      GroundOverlay.new(
        uri: absolute_path(go.search('Icon href').text),
        north: go.search('LatLonBox north').text,
        south: go.search('LatLonBox south').text,
        east: go.search('LatLonBox east').text,
        west: go.search('LatLonBox west').text
      )
    end
  end

  ##
  # Returns a 2d array of images in their physical order.
  def organize_images

    # 1. Group rows (images with the same north value).
    # 2. convert to array [north, [<GroundOverlay>]].
    # 3. then sort the groups ofrows by descending north value.
    # 4. then sort each row by images east values.
    images.group_by(&:north)                # 1.
      .to_a                                 # 2.
      .sort_by(&:first).reverse             # 3
      .map { |_, row| row.sort_by(&:east) } # 4
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

  private

  ##
  # Temporary shim before I real add support for kmz files.
  # This probably breaks kml's with links to the web.
  def absolute_path path
    File.join(File.dirname(@uri), path)
  end
end

class GroundOverlay
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
