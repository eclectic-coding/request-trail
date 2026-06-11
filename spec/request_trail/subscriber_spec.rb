# frozen_string_literal: true

RSpec.describe RequestTrail::Subscriber do
  describe ".attach" do
    it "returns a non-nil value" do
      expect(described_class.attach).not_to be_nil
    end

    it "is idempotent — returns the same object on repeated calls" do
      sub1 = described_class.attach
      sub2 = described_class.attach
      expect(sub1).to be(sub2)
    end

    it "records sql events to the current collector" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("sql.active_record") { nil }

      expect(RequestTrail::Collector.current.sql_count).to eq(1)
    end

    it "accumulates sql duration" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("sql.active_record") { nil }

      expect(RequestTrail::Collector.current.sql_duration_ms).to be >= 0
    end

    it "records a cache hit" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("cache_read.active_support", hit: true) { nil }

      expect(RequestTrail::Collector.current.cache_hits).to eq(1)
      expect(RequestTrail::Collector.current.cache_misses).to eq(0)
    end

    it "records a cache miss" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("cache_read.active_support", hit: false) { nil }

      expect(RequestTrail::Collector.current.cache_misses).to eq(1)
      expect(RequestTrail::Collector.current.cache_hits).to eq(0)
    end

    it "records a cache write" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("cache_write.active_support") { nil }

      expect(RequestTrail::Collector.current.cache_writes).to eq(1)
    end

    it "records a controller action" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("process_action.action_controller", view_runtime: 22.0) { nil }

      expect(RequestTrail::Collector.current.action_duration_ms).to be >= 0
    end

    it "records view_runtime from the action payload" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("process_action.action_controller", view_runtime: 22.0) { nil }

      expect(RequestTrail::Collector.current.view_duration_ms).to be_within(0.1).of(22.0)
    end

    it "defaults view_duration_ms to 0 when view_runtime is absent" do
      described_class.attach
      RequestTrail::Collector.start

      ActiveSupport::Notifications.instrument("process_action.action_controller") { nil }

      expect(RequestTrail::Collector.current.view_duration_ms).to eq(0.0)
    end

    it "does nothing when no collector is active" do
      described_class.attach
      expect do
        ActiveSupport::Notifications.instrument("sql.active_record") { nil }
        ActiveSupport::Notifications.instrument("cache_read.active_support", hit: true) { nil }
        ActiveSupport::Notifications.instrument("cache_write.active_support") { nil }
        ActiveSupport::Notifications.instrument("process_action.action_controller", view_runtime: 5.0) { nil }
      end.not_to raise_error
    end
  end

  describe ".detach" do
    it "stops recording sql events" do
      described_class.attach
      described_class.detach

      RequestTrail::Collector.start
      ActiveSupport::Notifications.instrument("sql.active_record") { nil }

      expect(RequestTrail::Collector.current.sql_count).to eq(0)
    end

    it "stops recording cache events" do
      described_class.attach
      described_class.detach

      RequestTrail::Collector.start
      ActiveSupport::Notifications.instrument("cache_read.active_support", hit: true) { nil }

      expect(RequestTrail::Collector.current.cache_hits).to eq(0)
    end

    it "is safe to call when not attached" do
      expect { described_class.detach }.not_to raise_error
    end
  end
end