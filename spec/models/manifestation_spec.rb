require 'rails_helper'

describe Manifestation do
  describe '.safe_filename' do
    let(:manifestation) { Manifestation.new(title: title) }
    let(:title) { 'Some Title' }
    let(:author_name) { 'שאול טשרניחובסקי' }

    before do
      expect(manifestation).to receive(:author_string) { author_name }
    end

    let(:subject) { manifestation.safe_filename }

    it 'builds filename from title and author_string and replaces all non-alphanumeric non-hebrew characters with underscore' do
      expect(subject).to eq 'Some_Title_מאת_שאול_טשרניחובסקי'
    end

    context 'when resulting filename is longer than 250 characters' do
      let(:title) { Random.hex(120) } # hex 120 produces 240 characters string
      it 'truncates filename to 250 characters' do
        expect(subject).to eq "#{title}_מאת_שאול_"
      end
    end
  end
end