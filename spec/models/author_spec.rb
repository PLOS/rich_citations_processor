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

describe RichCitationsProcessor::Models::Author do

  describe "::new" do

    it "should create an Author" do
      expect(described_class.new).not_to be_nil
    end

    it "should create an Author with values" do
      instance = described_class.new(given:'J', family:'Smith', email:'joe@eample.com', affiliation:'PLOS')
      expect(instance).to have_attributes(given:'J', family:'Smith', email:'joe@eample.com', affiliation:'PLOS')

      instance = described_class.new(literal:'The PLOS Labs Team', email:'joe@eample.com', affiliation:'PLOS')
      expect(instance).to have_attributes(literal:'The PLOS Labs Team', email:'joe@eample.com', affiliation:'PLOS')
    end

  end

  describe "accessors" do

    it "should clear the given and family names when setting a literal value" do
      instance = described_class.new(given:'J', family:'Smith')
      expect(instance).to have_attributes(given:'J', family:'Smith', literal:nil)

      instance.literal = 'The PLOS Labs Team'
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')
    end

    it "should NOT clear the given and family names when setting a literal to nil" do
      instance = described_class.new(given:'J', family:'Smith')
      expect(instance).to have_attributes(given:'J', family:'Smith', literal:nil)

      instance.literal = nil
      expect(instance).to have_attributes(given:'J', family:'Smith', literal:nil)
    end

    it "should clear the literal when setting a given value" do
      instance = described_class.new(literal:'The PLOS Labs Team')
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')

      instance.given = 'J.'
      expect(instance).to have_attributes(given:'J.', family:nil, literal:nil)
    end

    it "should NOT clear the literal when setting the given value to nil" do
      instance = described_class.new(literal:'The PLOS Labs Team')
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')

      instance.given = nil
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')
    end

    it "should clear the literal when setting a family value" do
      instance = described_class.new(literal:'The PLOS Labs Team')
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')

      instance.family = 'Smith'
      expect(instance).to have_attributes(given:nil, family:'Smith', literal:nil)
    end

    it "should NOT clear the literal when setting the family value to nil" do
      instance = described_class.new(literal:'The PLOS Labs Team')
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')

      instance.family = nil
      expect(instance).to have_attributes(given:nil, family:nil, literal:'The PLOS Labs Team')
    end

  end

  describe "#inspect" do

    it "should return an inspection string if a literal is provided" do
      instance = described_class.new(literal:'The PLOS Labs Team')

      expect(instance.inspect).to eq('Author: The PLOS Labs Team')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should return an inspection string if given and fmaily names are provided" do
      instance = described_class.new(given:'J', family:'Smith')

      expect(instance.inspect).to eq('Author: Smith, J')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should return an inspection string if only a fmaily name is provided" do
      instance = described_class.new(family:'Smith')

      expect(instance.inspect).to eq('Author: Smith')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should return an inspection string if only a given name is provided" do
      instance = described_class.new(given:'Wilbur')

      expect(instance.inspect).to eq('Author: Wilbur')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should return an inspection string if no names are provided" do
      instance = described_class.new

      expect(instance.inspect).to eq('Author: <not provided>')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should include the email address if provided" do
      instance = described_class.new(given:'J', family:'Smith', email:'john@example.com')

      expect(instance.inspect).to eq('Author: Smith, J (john@example.com)')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should include the affiliation if provided" do
      instance = described_class.new(given:'J', family:'Smith', affiliation:'PLOS Labs')

      expect(instance.inspect).to eq('Author: Smith, J (PLOS Labs)')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

    it "should include the email address and affiliation if provided" do
      instance = described_class.new(given:'J', family:'Smith', email:'john@example.com', affiliation:'PLOS Labs')

      expect(instance.inspect).to eq('Author: Smith, J (john@example.com) (PLOS Labs)')
      expect(instance.inspect).to eq(instance.indented_inspect)
    end

  end

end
