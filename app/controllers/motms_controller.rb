class MotmsController < ApplicationController

  def index
    @motms = Motm.all
      .order(sort_column_ar + " " + sort_direction)
  end
  
end
