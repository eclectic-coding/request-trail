# frozen_string_literal: true

require "rails/generators"
require "generators/request_trail/install/install_generator"

RSpec.describe RequestTrail::Generators::InstallGenerator do
  let(:destination_root) { File.expand_path("../tmp/generators", __dir__) }
  let(:initializer_path) { File.join(destination_root, "config/initializers/request_trail.rb") }

  before do
    FileUtils.mkdir_p(destination_root)
    described_class.start([], destination_root: destination_root, quiet: true)
  end

  after { FileUtils.rm_rf(destination_root) }

  it "creates the initializer file" do
    expect(File).to exist(initializer_path)
  end

  it "includes the configure block" do
    expect(File.read(initializer_path)).to include("RequestTrail.configure")
  end

  it "documents all config options" do
    content = File.read(initializer_path)
    expect(content).to include("config.enabled")
    expect(content).to include("config.log_level")
    expect(content).to include("config.threshold_ms")
    expect(content).to include("config.ignore_paths")
    expect(content).to include("config.sample_rate")
  end

  it "includes commented-out logger and formatter options" do
    content = File.read(initializer_path)
    expect(content).to include("# config.logger")
    expect(content).to include("# config.formatter")
  end

  it "skips an existing initializer when invoked with --skip" do
    File.write(initializer_path, "# existing content\n")
    described_class.start([], destination_root: destination_root, quiet: true, behavior: :skip)
    expect(File.read(initializer_path)).to eq("# existing content\n")
  end
end