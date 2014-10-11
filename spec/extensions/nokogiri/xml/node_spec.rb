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

describe Nokogiri::XML::Node do

  def x(text)
    Nokogiri::XML::Document.parse(text)
  end

  describe '#replace_with_children' do

    it "should replace the node with it's children" do
      doc = x(<<-XML.strip_heredoc)
        <?xml version="1.0"?>
        <root>
          <a/><b><x/><y/></b><c/>
        </root>
      XML

      doc.at_css('b').replace_with_children

      expect(doc.to_xml).to eq(<<-XML.strip_heredoc)
                                <?xml version="1.0"?>
                                <root>
                                  <a/><x/><y/><c/>
                                </root>
                               XML


    end

    it "should accept a node with no children" do
      doc = x(<<-XML.strip_heredoc)
        <?xml version="1.0"?>
        <root>
          <a/><b></b><c/>
        </root>
      XML

      doc.at_css('b').replace_with_children

      expect(doc.to_xml).to eq(<<-XML.strip_heredoc)
                                <?xml version="1.0"?>
                                <root>
                                  <a/><c/>
                                </root>
      XML


    end

  end

  describe "#remove_attributes" do

    it "should remove all attributes" do
      node = x('<root><node a="1" b="2" c="3" d="4" e="5"/><root>').at_css('node')
      node.remove_attributes

      expect(node.to_xml).to eq('<node/>')
    end

    it "should remove a list of attributes" do
      node = x('<root><node a="1" b="2" c="3" d="4" e="5"/><root>').at_css('node')
      node.remove_attributes('b', :d)

      expect(node.to_xml).to eq('<node a="1" c="3" e="5"/>')
    end

    it "should take an except list" do
      node = x('<root><node a="1" b="2" c="3" d="4" e="5"/><root>').at_css('node')
      node.remove_attributes(except:['b',:d])

      expect(node.to_xml).to eq('<node b="2" d="4"/>')
    end

  end

end
