# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'
require_relative 'shared'
require 'support/builders/jats'

module RichCitationsProcessor

  RSpec.describe Parsers::JATS do
    include Spec::Builders::JATS

    let (:parser) { Parsers::JATS.new(xml) }
    let (:paper)  { parser.parse! }
    subject { parser }

    it_should_behave_like 'a parser'

    describe "Parsing" do

      it "should parse from a Nokogiri document" do
        expect(xml).to be_a_kind_of(Nokogiri::XML::Document)
        parser = Parsers::JATS.new(xml)
        parser.parse!
      end

      it "should parse from a String document" do
        xmls = xml.to_s
        parser = Parsers::JATS.new(xmls)
        parser.parse!
      end

      it "should parse a real document" do
        xml = get_fixture('journal.pone.0032408.jats.xml')
        xml = Nokogiri::XML.parse(xml)

        parser = RichCitationsProcessor::Parsers::JATS.new(xml)
        paper = parser.parse!
        serializer = RichCitationsProcessor::Serializers::JSON.new(paper)
        result = serializer.as_structured_data

        # puts MultiJson.dump(result, pretty:true)
        expected =MultiJson.load get_fixture('journal.pone.0032408.parser.json')
        expect(result).to eq(expected)
      end

    end

    describe "Identifier parsing" do

      it "Should parse out the identifier" do
        article_id '10.12345/1234.12345', :doi
        expect(paper.uri).to eq(URI::DOI.new('10.12345/1234.12345') )
      end

      it "Should do nothing if there is no valid identifier" do
        article_id '10.12345/1234.12345', :unknown
        expect(paper.uri).to be_nil
      end

      it "Should take the first valid identifier" do
        article_id '10.12345/1234.12345', :unknown
        article_id '10.12345/1234.12345', :doi
        expect(paper.uri).to eq(URI::DOI.new('10.12345/1234.12345') )
      end

      it "Should do nothing if there is no identifier to parse" do
        expect(paper.uri).to be_nil
      end

    end

    describe "Parsing of metadata (excluding authors, references and ccitation groups)" do

      it "should include the word count" do
        body 'here is <b>some</b> text'
        expect(paper.word_count).to eq(4)
      end

    end

  end

end