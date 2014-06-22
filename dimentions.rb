require 'geocoder'
require 'bigdecimal'
require 'bigdecimal/util'

module Dimentions
  def width
    north_width = Geocoder::Calculations.distance_between([@north, @west], [@north, @east])
    south_width = Geocoder::Calculations.distance_between([@south, @west], [@south, @east])
    return (north_width.to_d + south_width.to_d) / 2
  end

  def height
    east_width = Geocoder::Calculations.distance_between([@north, @east], [@south, @east])
    west_width = Geocoder::Calculations.distance_between([@north, @west], [@south, @west])
    return (east_width.to_d + west_width.to_d) / 2
  end
end


