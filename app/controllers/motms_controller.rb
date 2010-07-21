class MotmsController < ApplicationController

  def index
    @motms = Motm.all(:order => :created_at)
  end
  
end
