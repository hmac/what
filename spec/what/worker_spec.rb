# frozen_string_literal: true

require "spec_helper"

require "date"

RSpec.describe What::Worker do
  let(:queue) { "default" }
  subject do
    -> { described_class.new.work(queue) }
  end

  describe ".work" do
    context "with a single job on the default queue" do
      before do
        CreatePayment.enqueue(5)
      end

      it "works and then destroys the job" do
        expect(WhatJob.count).to eq(1)
        subject.call
        expect(Payment.count).to eq(1)
        expect(WhatJob.count).to eq(0)
      end
    end

    context "with multiple jobs on the default queue" do
      before do
        CreatePayment.enqueue(3)
        CreatePayment.enqueue(4)
      end

      it "works one job" do
        expect(WhatJob.count).to eq(2)
        subject.call
        expect(Payment.count).to eq(1)
        subject.call
        expect(Payment.count).to eq(2)
        expect(WhatJob.count).to eq(0)
      end
    end

    context "with jobs on different queues" do
      before do
        CreatePayment.enqueue(1)
        CreatePayment.queue = "other_queue"
        CreatePayment.enqueue(2)
        CreatePayment.queue = nil
      end

      let(:queue) { "other_queue" }

      it "works only the jobs on the specified queue" do
        subject.call
        subject.call

        expect(WhatJob.count).to eq(1)
        expect(WhatJob.first.queue).to eq("default")
      end
    end

    context "with a job scheduled to run in the future" do
      before do
        CreatePayment.enqueue(1, run_at: Date.today + 100)
      end

      it "doesn't work the job" do
        subject.call
        expect(WhatJob.count).to eq(1)
        expect(WhatJob.first.failed_at).to eq(nil)
      end
    end
  end
end
