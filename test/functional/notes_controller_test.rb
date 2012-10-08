require 'test_helper'

class NotesControllerTest < ActionController::TestCase

  test "request for non-existent note item redirects" do
    get :show, :id => 1111
    assert_response :redirect, "Redirect away from non-existent note"
  end

  test "request for note with missing file redirects" do
    n = FactoryGirl.create(:note)
    get :show, :id => n.id
    assert_response :redirect, "Redirect away from note with mising file"
    assert_not_nil assigns(@speaker), "Set speaker for note listing"
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
    assert_not_nil assigns(@speaker), "Set speaker for note listing"
  end

end
