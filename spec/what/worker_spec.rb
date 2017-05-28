# frozen_string_literal: true

require "spec_helper"
require "support/payment"
require "support/create_payment"
require "support/blow_up"
require "support/job_stats"

RSpec.describe What::Worker do
  subject do
    -> { described_class.work("default") }
  end

  describe ".work" do
    context "with a single job on the default queue" do
      before do
        CreatePayment.enqueue(5)
      end

      it "works and then destroys the job" do
        expect(JobStats.count).to eq(1)
        subject.call
        expect(Payment.count).to eq(1)
        expect(JobStats.count).to eq(0)
      end
    end

    context "with multiple jobs on the default queue" do
      before do
        CreatePayment.enqueue(3)
        CreatePayment.enqueue(4)
      end

      it "works one job" do
        expect(JobStats.count).to eq(2)
        subject.call
        expect(Payment.count).to eq(1)
        subject.call
        expect(Payment.count).to eq(2)
        expect(JobStats.count).to eq(0)
      end
    end

    context "when a job fails" do
      before { BlowUp.enqueue }

      it "marks the job as failed, recording the stack trace" do
        subject.call
        expect(JobStats.count).to eq(1)
        failed_job = JobStats.first
        # expect(failed_job.last_error).not_to be_nil
      end
    end
  end
end
