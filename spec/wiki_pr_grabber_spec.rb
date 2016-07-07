require 'spec_helper'
require_relative '../lib/wiki_pr_grabber'

describe WikiPrGrabber do
  describe '#grab_pr_tables' do
    it 'works on single table case' do
      VCR.use_cassette "single table page" do
        page = HTTPClient.new.get("http://www.ssbwiki.com/Alabama_Power_Rankings").body
        doc = Nokogiri::HTML.parse page
        expect(subject.grab_pr_tables(doc).size).to eql 1
      end
    end
    it 'works on multi table case' do
      VCR.use_cassette "multi table page" do
        page = HTTPClient.new.get("http://www.ssbwiki.com/Colorado_Power_Rankings").body
        doc = Nokogiri::HTML.parse page
        expect(subject.grab_pr_tables(doc).size).to eql 5
      end
    end
  end

  describe '#parse_table' do
    it 'returns player map given ranking table' do
      table_text = File.open('spec/files/sample_table.html', 'rb').read
      table_element = Nokogiri::HTML.parse(table_text)
      expect(subject.parse_table(table_element)).to eql ({"Syrox" => "1", "Eikelmann" => "2"})
    end
  end
end