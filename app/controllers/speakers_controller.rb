class SpeakersController < ApplicationController

  def index
    @speakers = Speaker.all(:order => :last_name)
  end
  
end
