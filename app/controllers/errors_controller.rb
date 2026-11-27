class ErrorsController < ApplicationController

  # Rails hands unmatched URLs and exceptions here (config.exceptions_app),
  # so the status has to be set explicitly or the page goes out as a 200.
  # Always HTML: a probe for /foo.php or /x.json must not fail on a missing
  # template for that format.
  def not_found
    render :not_found, status: :not_found, formats: [:html], content_type: 'text/html'
  end

  def error
    render :error, status: :internal_server_error, formats: [:html], content_type: 'text/html'
  end

end
