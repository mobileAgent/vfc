class MotmsController < ApplicationController

  def index
    @motms = Motm.find(:all, :order => 'created_at desc')
  end
  
end
