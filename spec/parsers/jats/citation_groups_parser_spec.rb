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
require 'support/builders/jats'

module RichCitationsProcessor

  RSpec.describe Parsers::JATS::CitationGroupParser do
    include Spec::Builders::JATS

    let (:parser)      { Parsers::JATS.new(xml) }
    let (:paper)       { parser.parse! }
    let (:first_group) { paper.citation_groups.first }

    context "Grouping" do

      before do
        refs 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth', 'Ninth', 'Tenth', 'Eleventh', 'Twelfth'
      end

      it "should add a citation group" do
        body "some text #{cite(2)} with a reference."

        expect( first_group.references ).to eq( [ paper.references.second ] )
      end

      it "should add no groups if there are no citations" do
        body "some text without a reference."

        expect( paper.citation_groups ).to be_empty
      end

      it "should add multiple citation groups" do
        body "some text #{cite(2)} with a reference."
        body "more text #{cite(3)} with a reference."

        expect( paper.citation_groups.first.references  ).to eq( [ paper.references.second ] )
        expect( paper.citation_groups.second.references ).to eq( [ paper.references.third  ] )
      end

      it "should create a group for adjacent citations" do
        body "some text #{cite(2)}#{cite(4)} with a reference."

        expect( first_group.references  ).to eq( [ paper.references.second,
                                                   paper.references.fourth ] )
      end

      it "should create a group for citations separated by a comma" do
        body "some text #{cite(2)}, #{cite(4)} with a reference."

        expect( first_group.references  ).to eq( [ paper.references.second,
                                                   paper.references.fourth ] )
      end

      it "should create a group for a citation range" do
        body "some text #{cite(2)} - #{cite(4)} with a reference."

        expect( first_group.references  ).to eq( [ paper.references.second,
                                                   paper.references.third,
                                                   paper.references.fourth ] )
      end

      it "should create a cgroup for a citation followed by nothing but a hyphen" do
        body "some text #{cite(2)} -"

        expect( first_group.references  ).to eq( [ paper.references.second ] )
      end

      it "should create a group with combined citations" do
        body "some text #{cite(1)}, #{cite(5)}-#{cite(7)}, #{cite(3)}, #{cite(9)}-#{cite(11)} with a reference."

        expect( first_group.references  ).to eq( [ paper.references[0],
                                                   paper.references[4],
                                                   paper.references[5],
                                                   paper.references[6],
                                                   paper.references[2],
                                                   paper.references[8],
                                                   paper.references[9],
                                                   paper.references[10] ] )
      end

    end

    describe "#section" do

      before do
        refs 'First'
      end

      it "should include the section title" do
        body "<sec><title>Title 1</title>Some text #{cite(1)} More text<sec>"
        expect(first_group.section).to eq('Title 1')
      end

      it "should include the outermost section title" do
        body "<sec><title>Title 1</title>"
        body "<sec><title>Title 2</title>Some text #{cite(1)} More text</sec>"
        body "</sec>"
        expect(first_group.section).to eq('Title 1')
      end

      it "should include the outermost section that has a title" do
        body "<sec>"
        body "<sec><title>Title 2</title>Some text #{cite(1)} More text</sec>"
        body "</sec>"
        expect(first_group.section).to eq('Title 2')
      end

      it "should include nothing if there is no section" do
        body "<p><title>Title 2</title>Some text #{cite(1)} More text</p>"
        expect(first_group.section).to be_nil
      end

      it "should include nothing if the section has no title" do
        body "<sec>Some text #{cite(1)} More text</sec>"
        expect(first_group.section).to be_nil
      end

    end

    describe "#word_position" do

      before do
        refs 'First'
      end

      it "should include the position of the context" do
        body "Some text #{cite(1)} More text"
        expect(first_group.word_position).to eq(3)
      end

      it "should deal with nested elements" do
        body "Some <b>text</b> <a>#{cite(1)}</a> More text"
        expect(first_group.word_position).to eq(3)
      end

    end

    describe "#context" do

      before do
        refs 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth'
      end

      it "should provide citation context" do
        body "Some text #{cite(1)} More text"
        expect(first_group).to have_attributes(citation:    "[1]",
                                               text_before: "Some text ",
                                               text_after:  " More text",
                                              )
      end

      it "should provide the correct text for a group with multiple references context" do
        body "  Some text #{cite(1)}, #{cite(3)} - #{cite(5)} More text  "
        expect(first_group).to have_attributes(citation:    "[1], [3] - [5]",
                                               text_before: "Some text ",
                                               text_after:  " More text",
                                              )
      end

      it "should include truncation" do
        before = (1..25).to_a.reverse.join(" ")
        after  = (1..15).to_a.join(" ")
        body "#{before} #{cite(1)} #{after}."

        expected_before = (1..20).to_a.reverse.join(" ")+' '
        expected_after  = ' '+(1..10).to_a.join(" ")

        expect(first_group).to have_attributes(citation:         "[1]",
                                               truncated_before: true,
                                               truncated_after:  true,
                                               text_before:      expected_before,
                                               text_after:       expected_after,
                                           )
      end

      it "should include truncation as long as there is text before" do
        before = (1..10).to_a.reverse.join(" ")
        after  = (1..5).to_a.join(" ")
        body "#{before} #{cite(1)} #{after}."

        expected_before = (1..10).to_a.reverse.join(" ")+' '
        expected_after  = ' '+(1..5).to_a.join(" ")+'.'
        expect(first_group).to have_attributes(citation:         "[1]",
                                               truncated_before: false,
                                               truncated_after:  false,
                                               text_before:      expected_before,
                                               text_after:       expected_after,
                               )
      end

      it "should set the truncation flag to nil if there is no text before" do
        before = ''
        after  = (1..5).to_a.join(" ")
        body "#{before} #{cite(1)} #{after}."
        expect(first_group).to have_attributes(citation:         "[1]",
                                               truncated_before: nil
                               )
      end

      it "should set the truncation flag to nil if there is no text after" do
        before = (1..5).to_a.join(" ")
        after  = ''
        body "#{before} #{cite(1)} #{after}"

        expect(first_group).to have_attributes(citation:         "[1]",
                                               truncated_after: nil
                               )
      end

      it "should be limited to the nearest section" do
        body "<sec>abc<sec>"
        body "Some text #{cite(1)} More text"
        body "</sec>def</sec>"
        expect(first_group).to have_attributes(citation:   "[1]",
                                               text_after: " More text",
                                               text_before: "Some text "
                                             )
      end

      it "should be limited to the nearest paragraph" do
        body "<sec>abc<P>"
        body "Some text #{cite(1)} More text"
        body "</P>def</sec>"
        expect(first_group).to have_attributes(citation:   "[1]",
                                               text_after: " More text",
                                               text_before: "Some text "
                                             )

      end

    end

  end

end