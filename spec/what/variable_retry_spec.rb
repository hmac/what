# frozen_string_literal: true

require "spec_helper"

RSpec.describe What::Failure::VariableRetry do
  subject { -> { What::Worker.work("default") } }

  # TODO: The expectations on time here are quite race-prone
  # Since run_at is initially set by the database, the time won't
  # exactly match with the app's time (it tends to differ by microseconds).
  # To get around this, we truncate the times to seconds before comparing.

  before { BlowUpWithRetry.enqueue(exception) }

  context "when the job fails" do
    let(:now) { Time.now.utc }
    context "when the exception is retryable" do
      let(:exception) { nil }

      it "schedules it to run at the correct retry interval" do
        Timecop.freeze(now) { subject.call }

        expect(WhatJob.count).to eq(1)
        job = WhatJob.first

        expect(job.runnable).to eq(true)
        expect(job.error_count).to eq(1)
        expect(job.last_error).to match(/ExplosionError/)
        expect(job.run_at.to_i).to eq((now + 3600).to_i)
        expect(job.failed_at.to_i).to eq(now.to_i)
      end
    end

    context "when the exception isn't retryable" do
      let(:exception) { TypeError }

      it "does not retry the job" do
        Timecop.freeze(now) { subject.call }

        expect(WhatJob.count).to eq(1)
        job = WhatJob.first

        expect(job.runnable).to eq(false)
        expect(job.error_count).to eq(1)
        expect(job.last_error).to match(/TypeError/)
        expect(job.run_at.to_i).to eq(now.to_i)
        expect(job.failed_at.to_i).to eq(now.to_i)
      end
    end

    context "when the job fails a second time" do
      let(:exception) { nil }

      around do |example|
        original_retry_intervals = BlowUpWithRetry.retry_intervals
        example.run
        BlowUpWithRetry.retry_intervals = original_retry_intervals
      end

      context "if there's a second retry interval" do
        before { BlowUpWithRetry.retry_intervals = [0, 7200] }

        it "schedules the job to run at the next interval" do
          Timecop.freeze(now) { subject.call }
          Timecop.freeze(now) { subject.call }

          expect(WhatJob.count).to eq(1)
          job = WhatJob.first

          expect(job.runnable).to eq(true)
          expect(job.error_count).to eq(2)
          expect(job.last_error).to match(/ExplosionError/)
          expect(job.run_at.to_i).to eq((now + 7200).to_i)
          expect(job.failed_at.to_i).to eq(now.to_i)
        end
      end

      context "if there are no further retry intervals" do
        before { BlowUpWithRetry.retry_intervals = [0] }

        it "leaves the job in a failed state" do
          Timecop.freeze(now) { subject.call }
          Timecop.freeze(now) { subject.call }

          expect(WhatJob.count).to eq(1)
          job = WhatJob.first

          expect(job.runnable).to eq(false)
          expect(job.error_count).to eq(2)
          expect(job.last_error).to match(/ExplosionError/)
          expect(job.run_at.to_i).to eq(now.to_i)
          expect(job.failed_at.to_i).to eq(now.to_i)
        end
      end
    end
  end
end
