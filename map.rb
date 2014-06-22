require_relative './dimentions'
class Map
  attr_reader :image
  include Dimentions

  def initialize(image, n: n, s: s, e: e, w: w)
    @image = image;
    @north = n
    @south = s
    @east  = e
    @west  = w

    add_scale
  end

  def add_scale
    Magick::Draw.new
      .stroke('black')
      .stroke_width(10)
      .tap { |draw| draw.pointsize = 52 }
      .line(20 ,20 ,20 + scale, 20)
      .annotate(image, 0,0, 100, 100, "1 #{Geocoder::Configuration.units}")
      .draw(image)
  end

  def write(file)
    image.write(file)
  end

  ##
  # Units will be the pixels/default Geocoder unit.
  # width          width is in Geocoder's default units.
  # image.columns  columns is in number of pixels.
  def scale
    image.columns / width
  end

  def info
    [
      "resolution: #{image.rows}x#{image.columns}",
      "width: #{width.to_f} #{Geocoder::Configuration.units}",
      "height: #{height.to_f} #{Geocoder::Configuration.units}",
      "scale: #{(scale).to_f} pixel/#{Geocoder::Configuration.units}"
    ].join("\n")
  end

end
