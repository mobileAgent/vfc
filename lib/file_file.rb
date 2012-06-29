# Pretend to be like Carrierwave for the sake of zipline
class FileFile

  def initialize(name,mode="r")
    @file = File.new(name,mode)
  end

  def file
    @file
  end

end
