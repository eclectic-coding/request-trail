# frozen_string_literal: true

RSpec.describe RequestTrail::Subscriber do
  describe ".attach" do
    it "returns a subscription object" do
      expect(described_class.attach).not_to be_nil
    end

    it "is idempotent — returns the same subscription on repeated calls" do
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

    it "does nothing when no collector is active" do
      described_class.attach
      expect { ActiveSupport::Notifications.instrument("sql.active_record") { nil } }.not_to raise_error
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

    it "is safe to call when not attached" do
      expect { described_class.detach }.not_to raise_error
    end
  end
end