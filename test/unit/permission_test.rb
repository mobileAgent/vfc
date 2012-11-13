require 'test_helper'

class PermissionTest < Test::Unit::TestCase

  def test_admin_allowed_all_resources
    u = FactoryGirl.build(:user, :admin => true)
    p = Permission.new(u)
    assert p.allow?(:anything, :here),"All actions allowed to admin user"
    assert p.allow_param?(:anything, :here), "All params allowed to admin user"
  end

  def test_member_allowed_viewing_but_not_edit_resources
    u = FactoryGirl.build(:user)
    p = Permission.new(u)
    assert p.allow?(:audio_messages, :show),"Member can view audio messages"
    assert p.allow?(:speakers, :show),"Member can view speaker"
    assert p.allow?(:places, :show),"Member can view place"
    assert !p.allow?(:audio_messages, :edit),"Member cannot edit audio messages"
    assert !p.allow?(:speakers, :edit),"Member cannot edit speaker"
    assert !p.allow?(:places, :edit),"Member cannot edit place"
  end

  def test_editor_allowed_modification_of_audio_messages
    u = FactoryGirl.build(:user, :audio_message_editor => true)
    p = Permission.new(u)
    assert p.allow?(:audio_messages, :show), "Editor can view audio messages"
    assert p.allow?(:audio_messages, :edit), "Editor can request edit form for audio messages"
    assert p.allow?(:audio_messages, :update), "Editor can update audio messages"
    assert p.allow_param?(:audio_message, :title), "Editor can update message title"
    assert !p.allow_param?(:audio_message, :filesize), "Editor cannot update protected filesize"
  end
  
  def test_editor_allowed_modification_of_speaker
    u = FactoryGirl.build(:user, :speaker_editor => true)
    p = Permission.new(u)
    assert p.allow?(:speakers, :show), "Editor can view speaker"
    assert p.allow?(:speakers, :edit), "Editor can request edit form for speaker"
    assert p.allow?(:speakers, :update), "Editor can update speaker"
    assert p.allow_param?(:speaker,:first_name), "Editor can update speaker name"
    assert !p.allow_param?(:speaker, :hidden), "Editor cannot update speaker hidden flag"
  end
  
  def test_editor_allowed_modification_of_place
    u = FactoryGirl.build(:user, :place_editor => true)
    p = Permission.new(u)
    assert p.allow?(:places, :show), "Editor can view place"
    assert p.allow?(:places, :edit), "Editor can request edit form for place"
    assert p.allow?(:places, :update), "Editor can update place"
    assert p.allow_param?(:place, :name), "Editor can update place name"
  end

end
