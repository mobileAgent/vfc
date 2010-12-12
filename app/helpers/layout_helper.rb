module LayoutHelper
  
  def title(page_title = nil, show_title = true)
    content_for(:title, page_title ? "#{page_title}" : nil) 
    @show_title = show_title
  end

  def show_title?
    @show_title
  end
  
end
