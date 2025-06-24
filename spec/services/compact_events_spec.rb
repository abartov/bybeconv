# frozen_string_literal: true

require 'rails_helper'

describe CompactEvents do
  include ActiveSupport::Testing::TimeHelpers

  subject(:call) { described_class.call }

  let!(:manifestation) { create(:manifestation, orig_lang: 'ru') }
  let!(:author) { manifestation.authors.first }
  let!(:translator) { manifestation.translators.first }

  # Some events for 2025 (should not be affected)
  let!(:visit_end_of_2024) do
    create(:ahoy_visit, started_at: Time.zone.parse('2024-12-31 23:00:00'))
  end

  let!(:view_2025) do
    create(
      :ahoy_event,
      visit: visit_end_of_2024,
      name: 'view',
      record: author,
      time: Time.zone.parse('2025-01-01 01:00:00')
    )
  end
  let!(:download_2025) do
    create(
      :ahoy_event,
      visit: visit_end_of_2024,
      name: 'download',
      record: manifestation,
      time: Time.zone.parse('2025-01-01 01:00:00')
    )
  end

  let!(:manifestation_download_total) do
    create(:year_total, item: manifestation, event: 'download', year: 2024, total: 10)
  end
  let!(:author_view_total) { create(:year_total, item: author, event: 'view', year: 2024, total: 20) }

  before do
    # Set of records for 2024
    create_list(:ahoy_event, 5, name: 'view', record: manifestation, time: Time.zone.parse('2024-12-30 00:00:00'))
    create_list(:ahoy_event, 3, name: 'download', record: manifestation, time: Time.zone.parse('2024-11-01 00:00:00'))
    create_list(:ahoy_event, 7, name: 'view', record: author, time: Time.zone.parse('2024-10-01 00:00:00'))
    create_list(:ahoy_event, 4, name: 'view', record: translator, time: Time.zone.parse('2024-10-01 00:00:00'))

    # Some records for 2023
    create_list(:ahoy_event, 2, name: 'view', record: manifestation, time: Time.zone.parse('2023-10-01 00:00:00'))
  end

  it 'completes successfully' do
    travel_to Time.zone.parse('2025-01-01 12:00:00') do
      expect { call }.to change(Ahoy::Event, :count).by(-21)
                                                    .and change(YearTotal, :count).by(3)
                                                    .and change(Ahoy::Visit, :count).by(-21)
    end

    # Ensuring events from 2025 are not affected as well as their visit
    expect { view_2025.reload }.not_to raise_error
    expect { download_2025.reload }.not_to raise_error
    expect { visit_end_of_2024.reload }.not_to raise_error

    # Ensuring that already existed records for 2024 was properly updated
    manifestation_download_total.reload
    expect(manifestation_download_total.total).to eq(13) # 10 + 3

    author_view_total.reload
    expect(author_view_total.total).to eq(27) # 20 + 7

    # Ensuring new records was created
    expect(YearTotal.find_by!(event: 'view', year: 2024, item: manifestation).total).to eq(5)
    expect(YearTotal.find_by!(event: 'view', year: 2024, item: translator).total).to eq(4)
    expect(YearTotal.find_by!(event: 'view', year: 2023, item: manifestation).total).to eq(2)
  end
end
