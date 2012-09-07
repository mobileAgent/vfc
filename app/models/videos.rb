class Videos

  VIDEOS = {
    'Interview with Peter Brandon part 1' => 
    '/VFC-GOLD/Brandon_Peter/BrandonPeterVideoInterview2011part1.mp4',
    'Interview with Peter Brandon part 2' => 
    '/VFC-GOLD/Brandon_Peter/BrandonPeterVideoInterview2011part2.mp4',
    'Interview with Peter Brandon part 3' => 
    '/VFC-GOLD/Brandon_Peter/BrandonPeterVideoInterview2011part3.mp4',
    'Interview with Peter Brandon part 4' => 
    '/VFC-GOLD/Brandon_Peter/BrandonPeterVideoInterview2011part4.mp4',
    'Interview with Peter Brandon part 5' => 
    '/VFC-GOLD/Brandon_Peter/BrandonPeterVideoInterview2011part5.mp4',
    'Interview with Peter Brandon part 6' => 
    '/VFC-GOLD/Brandon_Peter/BrandonPeterVideoInterview2011part6.mp4'
  }

  def self.url_for(video_file)
    video_file.gsub(/VFC-GOLD/,'videos/file?name=')
  end

end
