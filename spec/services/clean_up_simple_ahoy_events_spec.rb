# frozen_string_literal: true

require 'rails_helper'

describe CleanUpSimpleAhoyEvents do
  self.use_transactional_tests = false

  subject(:call) { described_class.call }

  let!(:old_visit) { create(:ahoy_visit, started_at: (described_class::CLEAN_UP_THRESHOLD + 1.day).ago) }
  let!(:old_simple_event) do
    create(:ahoy_event, visit: old_visit, time: (described_class::CLEAN_UP_THRESHOLD + 1.hour).ago)
  end
  let!(:not_so_old_simple_event) do
    create(:ahoy_event, visit: old_visit, time: (described_class::CLEAN_UP_THRESHOLD - 1.hour).ago)
  end

  let!(:second_old_simple_event) do
    create(:ahoy_event, time: (described_class::CLEAN_UP_THRESHOLD + 1.day).ago)
  end
  let!(:second_visit) { second_old_simple_event.visit }

  let!(:old_object_event) do
    create(:ahoy_event, :with_item, time: (described_class::CLEAN_UP_THRESHOLD + 5.months).ago)
  end

  after(:all) do
    clean_tables
  end

  it 'cleans up old simple ahoy events and their visits' do
    expect { call }.to change(Ahoy::Event, :count).by(-2).and change(Ahoy::Visit, :count).by(-1)

    expect { old_visit.reload }.not_to raise_error
    expect { not_so_old_simple_event.reload }.not_to raise_error
    expect { old_object_event.reload }.not_to raise_error
    expect { old_simple_event.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { second_old_simple_event.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { second_visit.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
