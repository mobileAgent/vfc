# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

places = Place.create([
                       {:name => "Turkey Hill Camp", :cc => 'us'},
                       { :name => "Storybook Lodge", :cc => 'us'},
                       { :name => "Ramseur, North Carolina", :cc => 'us'},
                       { :name => "Wilmington, North Carolina", :cc => 'us'},
                       { :name => "Dallas, Texas", :cc => 'us'},
                       { :name => "West Virginia", :cc => 'us'},
                       { :name => "St. Louis, Missouri", :cc => 'us'},
                       { :name => "Omaha, Nebraska", :cc => 'us'},
                       { :name => "Spanish Wells, Bahamas", :cc => 'bs'},
                       { :name => "Hollywood, Florida", :cc => 'us'},
                       { :name => "Camp Horizon, Florida", :cc => 'us'},
                       { :name => "Camp Living Water", :cc => 'us'},
                       { :name => "Galilee Bible Camp", :cc => 'ca'},
                       { :name => "Rockville, Maryland", :cc => 'us'},
                       { :name => "Durham, North Carolina", :cc => 'us'},
                       { :name => "Raleigh, North Carolina", :cc => 'us'},
                       { :name => "Vancouver, BC, Canada", :cc => 'ca'},
                       { :name => "Shannon Hills, North Carolina", :cc => 'us'},
                       { :name => "Greenwood Hills", :cc => 'us'}
                      ])

languages = Language.create([
                             { :name => 'English', :cc => 'us'},
                             { :name => 'US-English', :cc => 'us'},
                             { :name => 'UK-English', :cc => 'gb'},
                             { :name => 'French', :cc => 'ca'},
                             { :name => 'Portuguese', :cc => 'br'},
                             { :name => 'Spanish', :cc => 'es'}
                            ])

["Genesis 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50",
"Exodus 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40",
"Leviticus 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27",
"Numbers 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36",
"Deuteronomy 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34",
"Joshua 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24",
"Judges 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21",
"Ruth 1 2 3 4 ",
"1Samuel 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31",
"2Samuel 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20  21 22 23 24 ",
"1Kings 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22",
"2Kings 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 ",
"1Chronicles 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29",
"2Chronicles 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36",
"Ezra 1 2 3 4 5 6 7 8 9 10",
"Nehemiah 1 2 3 4 5 6 7 8 9 10 11 12 13",
"Esther 1 2 3 4 5 6 7 8 9 10",
"Job 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42",
"Psalm 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 8 1 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150",
"Proverbs 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31",
"Ecclesiastes 1 2 3 4 5 6 7 8 9 10 11 12",
"Song 1 2 3 4 5 6 7 8",
"Isaiah 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66",
"Jeremiah 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52",
"Lamentations 1 2 3 4 5",
"Ezekiel 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48",
"Daniel 1 2 3 4 5 6 7 8 9 10 11 12",
"Hosea 1 2 3 4 5 6 7 8 9 10 11 12 13 14",
"Joel 1 2 3",
"Amos 1 2 3 4 5 6 7 8 9",
"Obadiah 1",
"Jonah 1 2 3 4",
"Micah 1 2 3 4 5 6 7",
"Nahum 1 2 3",
"Habakkuk 1 2 3",
"Zephaniah 1 2 3",
"Haggai 1 2",
"Zechariah 1 2 3 4 5 6 7 8 9 10 11 12 13 14",
"Malachi 1 2 3 4",
"Matthew 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28",
"Mark 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16",
"Luke 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24",
"John 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21",
"Acts 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28",
"Romans 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16",
"1Corinthians 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16",
"2Corinthians 1 2 3 4 5 6 7 8 9 10 11 12 13",
"Galatians 1 2 3 4 5 6",
"Ephesians 1 2 3 4 5 6",
"Philippians 1 2 3 4",
"Colossians 1 2 3 4",
"1Thessalonians 1 2 3 4 5",
"2Thessalonians 1 2 3",
"1Timothy 1 2 3 4 5 6",
"2Timothy 1 2 3 4",
"Titus 1 2 3",
"Philemon 1",
"Hebrews 1 2 3 4 5 6 7 8 9 10 11 12 13",
"James 1 2 3 4 5",
"1Peter 1 2 3 4 5",
"2Peter 1 2 3",
"1John 1 2 3 4 5",
"2John 1",
"3John 1",
"Jude 1",
 "Revelation 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22"].each do |line|
  parts=line.split(/ /)
  book=parts.delete_at(0)
  Tag.create(:name => book)
  parts.each { |chap| Tag.create(:name => "#{book}#{chap}") }
end
  
%w(salvation testimony gospel camp eschatology prophecy worship heaven apologetics).each do |item|
  Tag.create(:name => item)
end
