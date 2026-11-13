require "test_helper"
require "selenium-webdriver"
Selenium::WebDriver.logger.level = :warn

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ] do |options|
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--no-sandbox") if Process.uid.zero?
  end
end
