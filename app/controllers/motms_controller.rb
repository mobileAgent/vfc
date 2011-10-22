class MotmsController < ApplicationController

  def index
    @motms = Motm.all
  end
  
end
