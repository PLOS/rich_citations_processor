# Copyright (c) 2014 Public Library of Science

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

describe RichCitationsProcessor::Formatters::JSON do

  let(:paper) { RichCitationsProcessor::Models::CitingPaper.new }
  subject { RichCitationsProcessor::Formatters::JSON.new(paper) }
  let(:json) { MultiJson.load( subject.format ) }

  describe "paper info" do

    it "should return the paper metadata" do
      paper.uri           = TestURI.new('http://example.com/a', source:'test')
      paper.word_count    = 42
      paper.bibliographic = { 'metadata' => 1 }

      expect(json).to eq( 'uri_source'=>'test', 'word_count' => 42, 'uri'=>'http://example.com/a', 'bibliographic'=>{'metadata'=>1} )
    end

    it "should not return nil fields" do
      expect(json).to eq( {} )
    end

  end

  shared_examples_for 'authors' do

    it "should include authors" do
      authors_list.add(family:'Smith')
      authors_list.add(family:'Brown')
      expect(json_authors).to eq( [ { 'family'=>'Smith'}, { 'family' => 'Brown' } ] )
    end

    it "should include authors with family/given names" do
      authors_list.add(family:'Smith', given:'John')
      expect(json_authors).to eq( [ { 'family'=>'Smith', 'given' => 'John' } ] )
    end

    it "should include authors with literal names" do
      authors_list.add(literal:'The PLOS Labs Team')
      expect(json_authors).to eq( [ { 'literal'=>'The PLOS Labs Team' } ] )
    end

    it "should include authors with emails" do
      authors_list.add(family:'Smith', given:'John', email:'john@example.com')
      expect(json_authors).to eq( [ { 'family'=>'Smith', 'given' => 'John', 'email' => 'john@example.com' } ] )
    end

    it "should include authors with affiliations" do
      authors_list.add(family:'Smith', given:'John', affiliation:'PLOS Labs')
      expect(json_authors).to eq( [ { 'family'=>'Smith', 'given' => 'John', 'affiliation' => 'PLOS Labs' } ] )
    end

    it "should include an empty object if no metadata is uspplied" do
      authors_list.add
      expect(json_authors).to eq( [ { } ] )
    end

  end

  describe "citing paper authors" do
    let(:json_authors) { json['bibliographic']['author']}
    let(:authors_list)  { paper.authors }

    include_examples 'authors'
  end

  describe 'references' do
    let(:references) { json['references']}

    it "should have references" do
      paper.references.add(id:'1', number:1)
      paper.references.add(id:'2', number:2)

      expect(references).to eq([{'id' => '1', 'number'=>1}, {'id'=>'2', 'number'=>2}])

    end

    it "should have metadata for each reference" do
      paper.references.add(id:'1', number:1, uri:TestURI.new('http://example.com/a'),
                           original_citation:'Citation', accessed_at:DateTime.new(2014, 10, 15, 14, 02, 42),
                           bibliographic: { 'metadata' => 42}  )

      expect(references).to eq([{"id"=>"1", "number"=>1, "uri_source"=>"test", "uri"=>"http://example.com/a",
                                 "accessed_at"=>"2014-10-15T14:02:42.000+00:00", "original_citation"=>"Citation", "bibliographic"=>{"metadata"=>42}}] );


    end

    it "should return empty metadata for unspecified properties" do
      paper.references.add()
      expect(references).to eq([{}])
    end

    describe "reference paper authors" do
      let(:json_authors) { references.first['bibliographic']['author']}
      let(:authors_list)  { paper.references.add.authors }

      include_examples 'authors'
    end

    describe "referenced citation groups" do

      it "should return list of cited groups" do
        r1 = paper.references.add(id:"r1")
        r2 = paper.references.add(id:"r2")
        g1 = paper.citation_groups.add(id:'g1')
        g2 = paper.citation_groups.add(id:'g2')
        g3 = paper.citation_groups.add(id:'g3')

        r1.citation_groups.add(g1)
        r1.citation_groups.add(g3)
        r1.citation_groups.add(g2)

        r2.citation_groups.add(g2)

        expect(references).to eq([{"id"=>"r1", "citation_groups"=>["g1", "g3", "g2"]}, {"id"=>"r2", "citation_groups"=>["g2"]}])
      end

    end

  end

  describe 'citation_groups' do
    let(:citation_groups) { json['citation_groups']}

    it "should have groups" do
      paper.citation_groups.add(id:'1')
      paper.citation_groups.add(id:'2')

      expect(citation_groups).to eq([{'id' => '1'}, {'id'=>'2'}])

    end

    it "should have metadata for each citation_groups" do
      paper.citation_groups.add(id:'1', section:'Section', word_position:42)

      expect(citation_groups).to eq([{"id"=>"1", "section"=>'Section', "word_position"=>42}])
    end

    it "should return empty metadata for unspecified properties" do
      paper.citation_groups.add()
      expect(citation_groups).to eq([{}])
    end

    describe "context" do

      it "should be returned" do
        paper.citation_groups.add(id: "g1",
                                  truncated_before: true,
                                  text_before:      'Before',
                                  citation:         'Citation',
                                  text_after:       'After',
                                  truncated_after:  true   )

        expect(citation_groups).to eq([{'id'=>'g1', "context"=>{"truncated_before"=>true,
                                                                "text_before"=>"Before",
                                                                "citation"=>"Citation",
                                                                "text_after"=>"After",
                                                                "truncated_after"=>true } } ] )
      end

      it "should not include nil values" do
        paper.citation_groups.add(id: "g1",
                                  citation:         'Citation')

        expect(citation_groups).to eq([{'id'=>'g1', "context"=>{"citation"=>"Citation"} }])
      end

      it "should not be returned if all the values are nil" do
        paper.citation_groups.add(id: "g1")

        expect(citation_groups).to eq([{'id'=>'g1'}])
      end

    end

    describe "referenced citation groups" do

      it "should return list of cited groups" do
        r1 = paper.references.add(id:'r1')
        r2 = paper.references.add(id:'r2')
        r3 = paper.references.add(id:'r3')
        g1 = paper.citation_groups.add(id:'g1')
        g2 = paper.citation_groups.add(id:'g2')

        g1.references.add(r1)
        g1.references.add(r3)
        g1.references.add(r2)

        g2.references.add(r2)

        expect(citation_groups).to eq([{"id"=>"g1", "references"=>["r1", "r3", "r2"]}, {"id"=>"g2", "references"=>["r2"]}])
      end

    end

  end

end
