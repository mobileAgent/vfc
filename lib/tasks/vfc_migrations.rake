require 'vfc_record'
require 'find'

namespace :vfc do
  desc "convert old vfc data into new structure"
  task :migrate => :environment do
    @table_name = ENV['table'] ? ENV['table'].to_sym : :vfc
    if @table_name != :vfc
      VfcRecord.table_name = @table_name
      records = VfcRecord.all
      VfcRecord.convert_records(records)
      count = records.size
    else
      count = VfcRecord.convert_all
    end
    puts "Converted #{count} #{@table_name} records into " +
      "#{AudioMessage.count} audio messages, " + 
      "#{Speaker.count} speakers, " +
      "#{Place.count} places"
  end

  desc "convert and load old biographies from files into db"
  task :load_biographies => :environment do
    dir = ARGV[1]
    unless dir && File.exists?(dir)
      puts "Specify directory where old bios live as argument"
      return
    end

    # process all of the .bio files
    Find.find(dir) do |d|
      next unless d.match /\.(html|bio)$/
      next if d.match /[0-9]\.bio$/ # e.g. McGeeJVernon6.bio
      image_url = nil
      bio = IO.read(d)
      bio.gsub!(/[\r\n]+/m,' ') # single line conversion
      bio.gsub!(/\s+/m,' ') # multiple contiguous ws to one 
      bio.gsub!(/<!DOCTYPE.*?<\/ul>/,'') # html header
      bio.gsub!(/<div id="footer".*/,'') #html footer
      bio.gsub!(/<\/?p[^>]*?>/m,"\n") # paragraphs => \n
      bio.gsub!(/<strong><span class="cap">(.)<\/span><\/strong>/,"\\1") # drop cap
      bio.gsub!(/<\/?(span|div|center|font)[^>]*>/m,'') # remove divs and spans
      bio.gsub!(/<h1[^>]*?>(.*?)<\/h1>\s*<h2>(.*?)<\/h2>/mi,"*\\1 \\2* ") # old title
      bio.gsub!(/<\/?(h\d)[^>]*?>/,' ') # remove header tags
      bio.gsub!(/<\/?ul>/m,"\n") # remove lists
      bio.gsub!(/<[bh]r ?\/?>/,"\n") # breaks and lines
      bio.gsub!(/<li>/," * ") # list items => " * foo"
      bio.gsub!(/<\/li>/,"\n") # terminate closing list items
      bio.gsub!(/<blockquote>(.*?)<\/blockquote>/,"\nbq. \\1\n")
      bio.gsub!(/<\/?(strong|em|i|b)>/m,"*") # bold => *foo*
      if bio.gsub!(/<(img|image) .*?src=['"]([^'">]+)['"].*?[^>]+\/?>/m,'') # images removed but capture file name
        image_url = $2
      end
      bio.gsub!(/<a .*?href=['"]([^'">]+)['"].*?>([^<]+)<\/a>/m,"[\\2](\\1)") #links => "blah":uri
      bio.gsub!(/" ?Read more\.*":..\/bios\/.*?\.html?/mi,'') # remove static bio
      
      # build old style speaker name from from bio file name
      dname = d.gsub(/.*\/(.*?)\.(bio|html|htm)/,"\\1").gsub(/([a-z])([A-Z])/,"\\1 \\2")
      dname.gsub!(/([A-Z])([A-Z])/,"\\1 \\2") unless dname.match /AMS|GB|JM|NFI/
      dname.gsub!(/(Ma?c) /,"\\1")
      
      image_url.gsub!(/^.*\//,'') if image_url      

      # turn it into a new style speaker name
      ln,fn,mn = VfcRecord.convert_speaker_name(dname)
      conditions = {:last_name => ln,:first_name => fn,:middle_name => mn }
      s = Speaker.find(:first, :conditions => conditions)

      # Load it up or report the error
      if s
        puts "Speaker #{s.id} #{s.catalog_name}"
        puts bio[0..25] + "..."
        puts "   => image is #{image_url}" if image_url
        puts "\n\n"
        s.bio = bio
        s.picture_file = image_url if image_url
        s.save!
      else
        puts "Missing speaker for #{d} => #{dname} => #{ln},#{fn},#{mn}"
      end
    end
  end

end
