# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'copyright_expiration rake task' do
  before(:all) do
    Rake.application.rake_require 'tasks/copyright_expiration'
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task['copyright_expiration'] }
  let(:current_year) { Time.zone.today.year }
  let(:target_year) { current_year - 71 }

  before do
    task.reenable # Allow the task to be run multiple times
  end

  describe 'dry-run mode (default)' do
    let!(:person_died_target_year) do
      create(:person, deathdate: "#{target_year}-05-15", birthdate: '1880-01-01')
    end
    let!(:authority_copyrighted) do
      create(:authority, person: person_died_target_year, intellectual_property: :copyrighted)
    end
    let!(:manifestation) do
      create(:manifestation, author: authority_copyrighted, intellectual_property: :copyrighted)
    end

    it 'does not update any records' do
      expect { task.invoke }.not_to change { authority_copyrighted.reload.intellectual_property }
    end

    it 'reports statistics' do
      expect { task.invoke }.to output(/Authorities:/).to_stdout
                            .and output(/Manifestations:/).to_stdout
    end

    it 'indicates dry-run mode' do
      expect { task.invoke }.to output(/Running in DRY-RUN mode/).to_stdout
    end
  end

  describe 'execute mode' do
    let!(:person_died_target_year) do
      create(:person, deathdate: "#{target_year}-05-15", birthdate: '1880-01-01')
    end
    let!(:authority_copyrighted) do
      create(:authority, person: person_died_target_year, intellectual_property: :copyrighted)
    end
    let!(:expression_copyrighted) do
      create(:expression, intellectual_property: :copyrighted)
    end
    let!(:manifestation) do
      create(:manifestation, expression: expression_copyrighted)
    end

    before do
      # Link the authority to the expression through involved_authority
      expression_copyrighted.work.involved_authorities.create!(
        role: :author,
        authority: authority_copyrighted
      )
    end

    it 'updates authority to public_domain' do
      expect { task.invoke('execute') }.to change { authority_copyrighted.reload.intellectual_property }
        .from('copyrighted').to('public_domain')
    end

    it 'updates expression to public_domain when all authorities are public_domain' do
      expect { task.invoke('execute') }.to change { expression_copyrighted.reload.intellectual_property }
        .from('copyrighted').to('public_domain')
    end

    it 'indicates execute mode' do
      expect { task.invoke('execute') }.to output(/Running in EXECUTE mode/).to_stdout
    end

    it 'reports updated statistics' do
      output = capture_stdout { task.invoke('execute') }
      expect(output).to match(/Updated: 1/)
    end
  end

  describe 'multiple authorities scenario' do
    let!(:person1_died_target_year) do
      create(:person, deathdate: "#{target_year}-05-15", birthdate: '1880-01-01')
    end
    let!(:authority1) do
      create(:authority, person: person1_died_target_year, intellectual_property: :copyrighted)
    end

    let!(:person2_died_earlier) do
      create(:person, deathdate: "#{target_year - 10}-03-20", birthdate: '1870-01-01')
    end
    let!(:authority2) do
      create(:authority, person: person2_died_earlier, intellectual_property: :public_domain)
    end

    let!(:expression_multi_author) do
      create(:expression, intellectual_property: :copyrighted)
    end
    let!(:manifestation_multi_author) do
      create(:manifestation, expression: expression_multi_author)
    end

    before do
      # Link both authorities to the work
      expression_multi_author.work.involved_authorities.create!(
        role: :author,
        authority: authority1
      )
      expression_multi_author.work.involved_authorities.create!(
        role: :author,
        authority: authority2
      )
    end

    it 'updates expression when all involved authorities are public_domain' do
      expect { task.invoke('execute') }.to change { expression_multi_author.reload.intellectual_property }
        .from('copyrighted').to('public_domain')
    end
  end

  describe 'mixed authorities scenario' do
    let!(:person_died_target_year) do
      create(:person, deathdate: "#{target_year}-05-15", birthdate: '1880-01-01')
    end
    let!(:authority1) do
      create(:authority, person: person_died_target_year, intellectual_property: :copyrighted)
    end

    let!(:person2_alive_copyrighted) do
      create(:person, deathdate: nil, birthdate: '1950-01-01')
    end
    let!(:authority2) do
      create(:authority, person: person2_alive_copyrighted, intellectual_property: :copyrighted)
    end

    let!(:expression_mixed) do
      create(:expression, intellectual_property: :copyrighted)
    end
    let!(:manifestation_mixed) do
      create(:manifestation, expression: expression_mixed)
    end

    before do
      # Link both authorities
      expression_mixed.work.involved_authorities.create!(
        role: :author,
        authority: authority1
      )
      expression_mixed.work.involved_authorities.create!(
        role: :author,
        authority: authority2
      )
    end

    it 'does not update expression if not all authorities are public_domain' do
      expect { task.invoke('execute') }.not_to change { expression_mixed.reload.intellectual_property }
    end

    it 'still updates the authority that died 71 years ago' do
      expect { task.invoke('execute') }.to change { authority1.reload.intellectual_property }
        .from('copyrighted').to('public_domain')
    end
  end

  describe 'already public_domain authority' do
    let!(:person_died_target_year) do
      create(:person, deathdate: "#{target_year}-05-15", birthdate: '1880-01-01')
    end
    let!(:authority_already_pd) do
      create(:authority, person: person_died_target_year, intellectual_property: :public_domain)
    end

    it 'skips authorities already marked as public_domain' do
      output = capture_stdout { task.invoke }
      expect(output).to match(/already public_domain, skipping/)
    end

    it 'does not count skipped authorities in updated count' do
      output = capture_stdout { task.invoke }
      expect(output).to match(/Would update: 0/)
    end
  end

  describe 'statistics reporting' do
    let!(:person1) { create(:person, deathdate: "#{target_year}-05-15", birthdate: '1880-01-01') }
    let!(:authority1) { create(:authority, person: person1, intellectual_property: :copyrighted) }
    let!(:person2) { create(:person, deathdate: "#{target_year}-08-20", birthdate: '1885-01-01') }
    let!(:authority2) { create(:authority, person: person2, intellectual_property: :copyrighted) }

    it 'reports correct number of authorities checked' do
      output = capture_stdout { task.invoke }
      expect(output).to match(/Checked: 2/)
    end

    it 'reports correct number of authorities to update' do
      output = capture_stdout { task.invoke }
      expect(output).to match(/Would update: 2/)
    end
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
