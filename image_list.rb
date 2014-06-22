require 'RMagick'

# Reopen the class to define these sane aliases for append.
class Magick::ImageList
  def append_horizontal
    append(false)
  end

  def append_vertical
    append(true)
  end
end

