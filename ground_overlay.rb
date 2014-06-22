require_relative './dimentions'

class GroundOverlay
  attr_reader :uri, :north, :south, :east, :west
  include Dimentions

  def initialize(uri: uri, n: n, s: s, e: e, w: w)
    @uri = uri;
    @north = n
    @south = s
    @east  = e
    @west  = w
  end

  def width_in_miles
    north_width = Geocoder::Calculations.distance_between([@north, @west], [@north, @east])
    south_width = Geocoder::Calculations.distance_between([@south, @west], [@south, @east])
    return north_width + south_width / 2
  end

  def height_in_miles
    east_width = Geocoder::Calculations.distance_between([@north, @east], [@south, @east])
    west_width = Geocoder::Calculations.distance_between([@north, @west], [@south, @west])
    return east_width + west_width / 2
  end
end

