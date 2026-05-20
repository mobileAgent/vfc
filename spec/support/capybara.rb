require 'capybara/rspec'

# rack_test is the in-process driver: fast, no JS execution. Use it for
# everything until we hit a flow that needs JS, then revisit (likely with
# selenium-webdriver + chromedriver in a separate container).
Capybara.default_driver  = :rack_test
Capybara.javascript_driver = :rack_test
Capybara.default_max_wait_time = 5

# Make page.status_code work consistently in rack_test.
Capybara.raise_server_errors = true
