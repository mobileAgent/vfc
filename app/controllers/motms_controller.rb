class MotmsController < ApplicationController

  def index
    @motm = Rails.cache.fetch('motm',:expires_in => 30.minutes) {
      Motm.active.last
    }
    @motms = Motm.find(:all, :order => "created_at desc")
  end
  
end
