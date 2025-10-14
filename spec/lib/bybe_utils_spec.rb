# frozen_string_literal: true

require 'rails_helper'

describe BybeUtils do
  let(:test_class) do
    Class.new do
      include BybeUtils
    end
  end
  let(:instance) { test_class.new }

  describe '#footnotes_noncer' do
    let(:html_with_footnotes) do
      <<~HTML
        <p>Text with footnote<a href="#fn:1" id="fnref:1"><sup>1</sup></a>.</p>
        <ol>
          <li id="fn:1">
            <p>Footnote text <a href="#fnref:1">↩</a></p>
          </li>
        </ol>
      HTML
    end

    it 'adds nonce to footnote reference anchor href' do
      result = instance.footnotes_noncer(html_with_footnotes, 'test')
      expect(result).to include('href="#fn:test_1"')
    end

    it 'adds nonce to footnote reference anchor id' do
      result = instance.footnotes_noncer(html_with_footnotes, 'test')
      expect(result).to include('id="fnref:test_1"')
    end

    it 'adds nonce to footnote body anchor id' do
      result = instance.footnotes_noncer(html_with_footnotes, 'test')
      expect(result).to include('id="fn:test_1"')
    end

    it 'adds nonce to back-reference from footnote body' do
      result = instance.footnotes_noncer(html_with_footnotes, 'test')
      expect(result).to include('href="#fnref:test_1"')
    end

    it 'does not leave any non-nonced footnote anchors' do
      result = instance.footnotes_noncer(html_with_footnotes, 'test')
      expect(result).not_to include('href="#fn:1"')
      expect(result).not_to include('id="fnref:1"')
      expect(result).not_to include('id="fn:1"')
    end

    it 'handles multiple footnotes with different nonces' do
      html_with_multiple = <<~HTML
        <p>Text with footnote<a href="#fn:1" id="fnref:1"><sup>1</sup></a> and another<a href="#fn:2" id="fnref:2"><sup>2</sup></a>.</p>
        <ol>
          <li id="fn:1">
            <p>First footnote <a href="#fnref:1">↩</a></p>
          </li>
          <li id="fn:2">
            <p>Second footnote <a href="#fnref:2">↩</a></p>
          </li>
        </ol>
      HTML

      result = instance.footnotes_noncer(html_with_multiple, 'abc')
      expect(result).to include('fn:abc_1')
      expect(result).to include('fn:abc_2')
      expect(result).to include('fnref:abc_1')
      expect(result).to include('fnref:abc_2')
    end
  end
end
