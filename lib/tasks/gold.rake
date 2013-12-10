namespace :gold do

  desc "check to see if files exist and make a report on what is missing"
  task :filecheck => :environment do

    if ENV['speaker_id']
      speaker = Speaker.find(ENV['speaker_id'].to_i)
      puts "Validating files for #{speaker.catalog_name} (#{speaker.id})"
      records = speaker.audio_messages
    else
      puts "Validating all active records"
      records = AudioMessage.active
    end

    missing = []
    unreadable = []
    zerosize = []
    wrongsize = []
    perfect = 0
    checked = 0

    records.each do |r|
      fn = AUDIO_PATH + r.filename
      checked += 1
      if File.exist?(fn)
        if File.readable?(fn)
          size = File.size(fn)
          if size == r.filesize
            perfect += 1
          elsif size == 0
            zerosize << r.filename
          else
            wrongsize << r.filename
          end
        else
          unreadable << r.filename
        end
      else
        missing << r.filename
      end
    end

    puts "Checked #{checked} audio records"
    puts "  - #{perfect} records were ok" if perfect > 0
    puts "  - #{wrongsize.size} records were ok but had the wrong size" if wrongsize.size  > 0
    puts "  - #{zerosize.size} records had files of zero size" if zerosize.size > 0
    puts "  - #{unreadable.size} records had unreadable files" if unreadable.size > 0
    puts "  - #{missing.size} files were missing" if missing.size > 0

    if 'true' == ENV['verbose']
      puts "\n\nMissing Files:\n   " + missing.join("\n   ") if missing.size > 0
      puts "\n\nUnreadable Files:\n   " + unreadable.join("\n   ") if unreadable.size > 0
      puts "\n\nZerosize Files:\n   " + zerosize.join("\n   ") if zerosize.size > 0
      # puts "\n\nWrong size:\n   " + wrongsize.join("\n   ") if wrongsize.size > 0
    end
  end
  
  desc "rename the files so that they match the expected download name"
  task :rename_as_download => :environment do

    unless ENV['speaker_id']
      fail "You must specify a speaker id"
    end

    move_count = 0
    speaker = Speaker.find(ENV['speaker_id'].to_i)
    puts "Renaming files for #{speaker.catalog_name} (#{speaker.id})"
    sdir = speaker.audio_directory_name
    FileUtils.mkdir_p(AUDIO_PATH + sdir)

    speaker.audio_messages.active.each do |r|
      current = AUDIO_PATH + r.filename
      fpart = r.title.parameterize.downcase.gsub(/[^-a-z0-9]+/,'-')
      expected = AUDIO_PATH + sdir + "/" + fpart + ".mp3"
      if current != expected
        if File.exist?(expected)
          fcounter = 1
          while File.exist?(expected) do
            expected = AUDIO_PATH + sdir + "/" + fpart + "-" + fcounter.to_s + ".mp3"
            fcounter += 1
          end
        end
        if File.rename(current,expected)
          r.update_attributes(:filename => expected.gsub(/^#{AUDIO_PATH}/,''))
          move_count += 1
        end
      end
    end
    puts "Moved #{move_count} files"
  end

  desc "load true file sizes from files on disk"
  task :update_filesizes => :environment do

    unless ENV['speaker_id']
      fail "You must specify a speaker id"
    end

    update_count = 0
    speaker = Speaker.find(ENV['speaker_id'].to_i)
    speaker.audio_messages.active.each do |r|
      db_size = r.filesize
      real_size = File.size(AUDIO_PATH + r.filename)
      if db_size != real_size
        r.update_attributes(:filesize => real_size)
        update_count += 1
      end
    end
    puts "Updated sizes for #{update_count} files by #{speaker.full_name}"
  end
    
end
