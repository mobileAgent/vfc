require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  test "show all notes" do
    n = FactoryGirl.create(:note)
    get :index
    assert_response :success, "Show all notes"
    assert_not_nil assigns(@notes), "Notes should be set for listing"
  end


  test "request for non-existent note item redirects" do
    get :show, :id => 1111
    assert_response :redirect, "Redirect away from non-existent note"
  end

  test "request for note with missing file redirects" do
    n = FactoryGirl.create(:note)
    get :show, :id => n.id
    assert_response :redirect, "Redirect away from note with mising file"
    assert_not_nil assigns(:speaker), "Set speaker for note listing"
  end

  test "request for notes list by speaker" do
    s = FactoryGirl.create(:speaker)
    n = FactoryGirl.create(:note, :speaker_id => s.id)
    get :speaker, :id => s.id
    assert_response :success, "Show notes list for speaker"
    assert_not_nil assigns(:notes), "Notes should be set for listing"
  end

  test "request for audio messages with notes by speaker" do
    s = FactoryGirl.create(:speaker)
    n = FactoryGirl.create(:note, :speaker_id => s.id)
    a = FactoryGirl.create(:audio_message, :speaker_id => s.id, :note_id => n.id)
    AudioMessage.expects(:search).returns([a].paginate)
    get :audio, :id => s.id
    assert_response :success, "Shows audio listing with notes"
    assert_not_nil assigns(:items), "Items should be assigned for audio listing"
    assert assigns(:items).size > 0,"Assigned items array must be size > 0"
  end

  test "request for audio messages with specified note by speaker" do
    s = FactoryGirl.create(:speaker)
    n = FactoryGirl.create(:note, :speaker_id => s.id)
    n2 = FactoryGirl.create(:note, :speaker_id => s.id)
    a = []
    [1..3].each { |x| a << FactoryGirl.create(:audio_message, :speaker_id => s.id, :note_id => n.id) }
    AudioMessage.expects(:search).returns(a.paginate)
    get :audio, :id => s.id, :note_id => n.id
    assert_response :success, "Shows audio listing with specified notes"
    assert_not_nil assigns(:items), "Items should be assigned for audio listing"
  end
  

  test "request for note file renders bytes" do
    n = FactoryGirl.create(:note, :filename => "NOTE_SPEAKER/foo.pptx")
    FileUtils.mkdir_p(File.dirname("#{NOTES_PATH}/#{n.filename}"))
    f = File.open("#{NOTES_PATH}/#{n.filename}","w")
    f.puts "test data"
    f.close
    get :show, :id => n.id
    File.delete("#{NOTES_PATH}/#{n.filename}")
    assert_response :success
  end
  
  test "request for note pdf file renders bytes" do
    n = FactoryGirl.create(:note, :filename => "NOTE_SPEAKER/foo.pdf")
    FileUtils.mkdir_p(File.dirname("#{NOTES_PATH}/#{n.filename}"))
    f = File.open("#{NOTES_PATH}/#{n.filename}","w")
    f.puts "test data"
    f.close
    get :show, :id => n.id
    File.delete("#{NOTES_PATH}/#{n.filename}")
    assert_response :success
  end

  test "request for notes by speaker shows list" do
    n = FactoryGirl.create(:note)
    get :speaker, :id => n.speaker.id
    assert_response :success
    assert_not_nil assigns(:speaker), "Set speaker for note listing"
  end

end
