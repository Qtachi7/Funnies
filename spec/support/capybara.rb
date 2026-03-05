require "capybara/playwright"
require "fileutils"

TRACE_DIR = Rails.root.join("tmp/capybara/traces")
FileUtils.mkdir_p(TRACE_DIR)

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: true,
  )
end

Capybara.default_driver    = :rack_test
Capybara.javascript_driver = :playwright

RSpec.configure do |config|
  config.before(:each, type: :system) do |example|
    driven_by :playwright

    # driven_by の後にトレース開始（driven_by がドライバーを再登録するため必ずこの順序で）
    page.driver.start_tracing(
      title:       example.full_description,
      screenshots: true,
      snapshots:   true,
    )
  end

  config.after(:each, type: :system) do |example|
    if example.exception
      # テスト失敗時のみ zip として保存
      safe_name = example.full_description.gsub(/[^\w\s\-]/, "").strip.gsub(/\s+/, "_")[0..100]
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      path      = TRACE_DIR.join("#{timestamp}_#{safe_name}.zip").to_s
      page.driver.stop_tracing(path: path)
      warn "\n[Playwright Trace] #{path}\n  → npx playwright show-trace #{path}\n"
    else
      page.driver.stop_tracing
    end
  end
end
