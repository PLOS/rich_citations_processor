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
require 'support/builders/nlm'

describe RichCitationsProcessor::Parsers::NLM do
  include Spec::Builders::NLM

  let (:parser) { RichCitationsProcessor::Parsers::NLM.new(xml) }
  let (:paper)  { parser.parse }

  describe "Parsing" do

    it "should parse from a Nokogiri document" do
      expect(xml).to be_a_kind_of(Nokogiri::XML::Document)
      parser = RichCitationsProcessor::Parsers::NLM.new(xml)
      parser.parse
    end

    it "should parse from a String document" do
      xmls = xml.to_s
      parser = RichCitationsProcessor::Parsers::NLM.new(xmls)
      parser.parse
    end

  end

  describe "Parsing references" do

    let (:reference) { paper.references.first }

    it "should parse references" do
      refs 'First', 'Second'

      expect(paper.references.count).to eq(2)
      expect(paper.references.second).to have_attributes(id:'ref-2', number:2, original_citation:'Second')
    end

    it "should remove the <label> from a reference" do
      refs '<label>1</label> First'

      expect(reference.original_citation).to eq('First')
    end

    def compare_html(input, expected)
      refs input

      # We need to parse the document similarly to get rid of odd spacing
      o = Nokogiri::HTML::DocumentFragment.parse(reference.original_citation).to_html
      o.gsub!(/^\s+|\s+$/,'')

      e = Nokogiri::HTML::DocumentFragment.parse(expected).to_html
      e.gsub!(/^\s+|\s+$/,'')

      expect(o).to eq(e)
    end

    it "should convert JATS markup to HTML (Example 1)" do
      input = <<-EOS
                <label>42</label>
                <element-citation publication-type="other" xlink:type="simple">
                   <person-group person-group-type="author">
                     <name name-style="western"><surname>Maddison</surname><given-names>DJ</given-names></name>
                   </person-group>
                   <year>2007</year><month>8</month><day>23</day>
                   <article-title>The perception of and adaptation to climate change in Africa.</article-title>
                   <comment>World Bank Policy Research Working Paper No 4308. Available at SSRN:
                       <ext-link ext-link-type="uri" xlink:href="http://ssrn.com/abstract=1005547" xlink:type="simple">http://ssrn.com/abstract=1005547</ext-link></comment>
                </element-citation>
              EOS

      expected = <<-EOS
                   <span class='citation' data-publicationtype="other"">
                      <span class='person-group'>
                        <span class='author'><span class='surname'>Maddison</span><span class='given-names'>DJ</span></span>
                      </span>
                      <span class='year'>2007</span><span class='month'>8</span><span class='day'>23</span>
                      <span class='article-title'>The perception of and adaptation to climate change in Africa.</span>
                      <span class='comment'>World Bank Policy Research Working Paper No 4308. Available at SSRN:
                          <a href="http://ssrn.com/abstract=1005547">http://ssrn.com/abstract=1005547</a></span>
                   </span>
                 EOS

      compare_html(input, expected)
    end

      it "should convert JATS markup to HTML (Example 2)" do
        input = <<-EOS
                  <label>44</label>
                  <mixed-citation publication-type="journal" xlink:type="simple">
                    <name name-style="western"><surname>Plachetzki</surname><given-names>DC</given-names></name>,
                    <name name-style="western"><surname>Degnan</surname><given-names>BM</given-names></name>,
                    <name name-style="western"><surname>Oakley</surname><given-names>TH</given-names></name>
                    (<year>2007</year>)
                    <article-title>The origins of novel protein interactions during animal opsin evolution</article-title>.
                    <source>PLoS One</source>
                    <volume>2</volume>: <fpage>e1054</fpage>-<lpage>e1055</lpage>.
                  </mixed-citation>
                EOS

        expected = <<-EOS
                  <span class='citation' data-publicationtype="journal">
                    <span class='author'><span class='surname'>Plachetzki</span><span class='given-names'>DC</span></span>,
                    <span class='author'><span class='surname'>Degnan</span><span class='given-names'>BM</span></span>,
                    <span class='author'><span class='surname'>Oakley</span><span class='given-names'>TH</span></span>
                    (<span class='year'>2007</span>)
                    <span class='article-title'>The origins of novel protein interactions during animal opsin evolution</span>.
                    <span class='source'>PLoS One</span>
                    <span class='volume'>2</span>: <span class='fpage'>e1054</span>-<span class='lpage'>e1055</span>.
                  </span>
        EOS

        compare_html(input, expected)
      end

    it "should convert JATS styles to HTML styles" do
      input = <<-EOS
                  <mixed-citation publication-type="journal" xlink:type="simple">
                    <article-title>
                      <i>Italic 1</i> - <italic>Italic 2</italic> - <em>Italic 3</em>
                      <b>Bold 1</b> - <bold>Bold 2</bold> - <strong>Bold 3</strong>
                    </article-title>.
                  </mixed-citation>
      EOS

      expected = <<-EOS
                  <span class='citation' data-publicationtype="journal">
                    <span class='article-title'>
                      <em>Italic 1</em> - <em>Italic 2</em> - <em>Italic 3</em>
                      <strong>Bold 1</strong> - <strong>Bold 2</strong> - <strong>Bold 3</strong>
                    </span>.
                  </span>
      EOS

      compare_html(input, expected)
    end

    it "should be case insensitive" do
      input = <<-EOS
                <mixed-citation publication-type="journal" xlink:type="simple">
                  <Article-Title>
                    <i>Italic 1</i> - <Italic>Italic 2</Italic> - <EM>Italic 3</EM>
                  </Article-Title>.
                </mixed-citation>
      EOS

      expected = <<-EOS
                <span class='citation' data-publicationtype="journal">
                  <span class='article-title'>
                    <em>Italic 1</em> - <em>Italic 2</em> - <em>Italic 3</em>
                  </span>.
                </span>
      EOS

      compare_html(input, expected)
    end

    it "should pass through specific tags" do
      input = <<-EOS
                <mixed-citation publication-type="journal" xlink:type="simple">
                  <article-title>
                    <q>Quote</q> <sub>script</sub> <a href="http://example.com">Link</a>
                  </article-title>.
                </mixed-citation>
      EOS

      expected = <<-EOS
                <span class='citation' data-publicationtype="journal">
                  <span class='article-title'>
                    <q>Quote</q> <sub>script</sub> <a href="http://example.com">Link</a>
                  </span>.
                </span>
      EOS

      compare_html(input, expected)
    end

    it "should ignore unknown tags" do
      input = <<-EOS
                <mixed-citation publication-type="journal" xlink:type="simple">
                  <some-tag>Tag Contents</some-tag>
                  <article-title>Article <blink>Title</blink></article-title>.
                </mixed-citation>
      EOS

      expected = <<-EOS
                <span class='citation' data-publicationtype="journal">
                  Tag Contents
                  <span class='article-title'>Article Title</span>.
                </span>
      EOS

      compare_html(input, expected)
    end

    it "should ignore unknown attributes" do
      input = <<-EOS
                  <mixed-citation unknown='attribute'>
                    <article-title href='http://example.com'>Article Title</article-title>.
                    <a unknown='attribute'>Link</a>
                  </mixed-citation>
      EOS

      expected = <<-EOS
                  <span class='citation'>
                    <span class='article-title'>Article Title</blink></span>.
                    <a>Link</a>
                  </span>
      EOS

      compare_html(input, expected)
    end

  end

end
