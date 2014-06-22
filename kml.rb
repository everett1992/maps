require 'RMagick'
require 'bigdecimal'
require 'nokogiri'
require_relative './dimentions'
require_relative './image_list'
require_relative './ground_overlay'
require_relative './map'

class Kml
  include Magick
  include Dimentions
  attr_reader :ground_overlays, :name

  def initialize(uri)
    @uri = uri

    doc = Nokogiri::XML(open(uri))

    @name = doc.search('kml Document name').text
    @ground_overlays = doc.search('kml Document GroundOverlay').map do |go|
      GroundOverlay.new(
        uri: absolute_path(go.search('Icon href').text),
        n: BigDecimal.new(go.search('LatLonBox north').text),
        s: BigDecimal.new(go.search('LatLonBox south').text),
        e: BigDecimal.new(go.search('LatLonBox east').text),
        w: BigDecimal.new(go.search('LatLonBox west').text)
      )
    end

    # Create a bounding box for the combined images.
    @north = BigDecimal.new ground_overlays.sort_by(&:north).last.north
    @south = BigDecimal.new ground_overlays.sort_by(&:south).first.south
    @east = BigDecimal.new ground_overlays.sort_by(&:east).last.east
    @west = BigDecimal.new ground_overlays.sort_by(&:west).first.west
  end

  ##
  # Returns a 2d array of ground overlays in their physical order.
  def organize_ground_overlays

    # 1. Group rows (ground_overlays with the same north value).
    # 2. convert to array [north, [<GroundOverlay>]].
    # 3. then sort the groups ofrows by descending north value.
    # 4. then sort each row by ground overlays east values.
    @organize_ground_overlays ||= ground_overlays.group_by(&:north)                # 1.
      .to_a                                 # 2.
      .sort_by(&:first).reverse             # 3
      .map { |_, row| row.sort_by(&:east) } # 4
  end

  ##
  # Returns the kml as a single image.
  def to_image
    map = ImageList.new
    map += organize_ground_overlays.map do |row|
      ImageList.new(*row.map(&:uri)).append_horizontal
    end
    map.append_vertical
  end

  ##
  # Add scale and compass rose to the image.
  def to_map
    Map.new(to_image, n: @north, s: @south, e: @east, w: @west)
  end

  private

  ##
  # Temporary shim before I real add support for kmz files.
  # This probably breaks kml's with links to the web.
  def absolute_path path
    File.join(File.dirname(@uri), path)
  end

end
