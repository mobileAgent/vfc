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

    missing = 0
    unreadable = 0
    zerosize = 0
    wrongsize = 0
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
            zerosize += 1
          else
            wrongsize += 1
          end
        else
          unreadable += 1
        end
      else
        missing += 1
      end
    end

    puts "Checked #{checked} audio records"
    puts "  - #{perfect} records were ok" if perfect > 0
    puts "  - #{wrongsize} records were ok but had the wrong size" if wrongsize > 0
    puts "  - #{zerosize} records had files of zero size" if zerosize > 0
    puts "  - #{unreadable} records had unreadable files" if unreadable > 0
    puts "  - #{missing} files were missing" if missing > 0
    
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
            expected = AUDIO_PATH + sdir + "/" + fpart + "-" + fcounter + ".mp3"
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
