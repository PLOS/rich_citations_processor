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
  let (:paper)  { parser.parse! }

  before do
    refs 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth', 'Ninth', 'Tenth', 'Eleventh', 'Twelfth'
  end

  it "should add a citation group" do
    body "some text #{cite(2)} with a reference."

    expect( paper.citation_groups.first.references ).to eq( [ paper.references.second ] )
  end

  it "should add multiple citation groups" do
    body "some text #{cite(2)} with a reference."
    body "more text #{cite(3)} with a reference."

    expect( paper.citation_groups.first.references  ).to eq( [ paper.references.second ] )
    expect( paper.citation_groups.second.references ).to eq( [ paper.references.third  ] )
  end

  it "should create a group for adjacent citations" do
    body "some text #{cite(2)}#{cite(4)} with a reference."

    expect( paper.citation_groups.first.references  ).to eq( [ paper.references.second,
                                                               paper.references.fourth ] )
  end

  it "should create a group for citations separated by a comma" do
    body "some text #{cite(2)}, #{cite(4)} with a reference."

    expect( paper.citation_groups.first.references  ).to eq( [ paper.references.second,
                                                               paper.references.fourth ] )
  end

  it "should create a group for a citation range" do
    body "some text #{cite(2)} - #{cite(4)} with a reference."

    expect( paper.citation_groups.first.references  ).to eq( [ paper.references.second,
                                                               paper.references.third,
                                                               paper.references.fourth ] )
  end

  it "should create a cgroup for a citation followed by nothing but a hyphen" do
    body "some text #{cite(2)} -"

    expect( paper.citation_groups.first.references  ).to eq( [ paper.references.second ] )
  end

  it "should create a group with combined citations" do
    body "some text #{cite(1)}, #{cite(5)}-#{cite(7)}, #{cite(3)}, #{cite(9)}-#{cite(11)} with a reference."

    expect( paper.citation_groups.first.references  ).to eq( [ paper.references[0],
                                                               paper.references[4],
                                                               paper.references[5],
                                                               paper.references[6],
                                                               paper.references[2],
                                                               paper.references[8],
                                                               paper.references[9],
                                                               paper.references[10] ] )
  end

end
