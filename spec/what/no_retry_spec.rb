# frozen_string_literal: true

require "spec_helper"

RSpec.describe What::Failure::NoRetry do
  subject { -> { Timecop.freeze { What::Worker.work("default") } } }

  before { BlowUp.enqueue }
  let(:now) { Time.now.utc }

  context "when the job fails" do
    it "marks the job as failed, recording the stack trace" do
      subject.call

      expect(WhatJob.count).to eq(1)
      job = WhatJob.first

      expect(job.runnable).to eq(false)
      expect(job.error_count).to eq(1)
      expect(job.last_error).to match(/oh noes!/)
      expect(job.runnable).to eq(false)
      expect(job.failed_at.to_i).to eq(now.to_i)
    end

    it "doesn't attempt to re-run the job" do
      subject.call
      subject.call

      expect(WhatJob.count).to eq(1)
      job = WhatJob.first

      expect(job.runnable).to eq(false)
      expect(job.error_count).to eq(1)
      expect(job.last_error).to match(/oh noes!/)
      expect(job.runnable).to eq(false)
      expect(job.failed_at.to_i).to eq(now.to_i)
    end
  end
end
