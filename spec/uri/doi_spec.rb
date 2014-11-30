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

module RichCitationsProcessor

  RSpec.describe URI::DOI do

    subject { described_class.new('identifier', source:'test') }
    
    it_should_behave_like 'a parseable uri'

    describe '::from_uri' do

      it "should parse a DOI from a URL" do
        uri = URI::DOI.from_uri('http://dx.doi.org/10.123/456', source:'foo')
        expect(uri.doi).to eq('10.123/456')
      end

      it "should return nil when a DOI could not be parsed" do
        expect( URI::DOI.from_uri('http://dx.doi.org/10.123456') ).to be_nil
        expect( URI::DOI.from_uri('http://dx.foo.org/10.123/456') ).to be_nil
        expect( URI::DOI.from_uri('10.123/456') ).to be_nil
        expect( URI::DOI.from_uri('some text') ).to be_nil
      end

    end

    describe '::from_text' do

      it "should parse a DOI from text" do
        uris = URI::DOI.from_text('http://dx.doi.org/10.123/456', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse multiple DOIs from text" do
        uris = URI::DOI.from_text('http://dx.doi.org/10.123/444 http://dx.doi.org/10.123/555', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/444', 'http://dx.doi.org/10.123/555'] )
      end

      it "should parse a DOI in URI format" do
        uris = URI::DOI.from_text('somethinghttp://dx.doi.org/10.123/456', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI in bare format at the start of a string" do
        uris = URI::DOI.from_text('10.123/456', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI in bare format after white-space" do
        uris = URI::DOI.from_text('text 10.123/456', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI in bare format after punctuation" do
        uris = URI::DOI.from_text('Did he go?10.123/456', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI in bare format at the end of a string" do
        uris = URI::DOI.from_text('10.123/456', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI in bare format ended by white-space" do
        uris = URI::DOI.from_text('10.123/456 some text', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI in bare format ended by" do
        uris = URI::DOI.from_text('10.123/456: But then there were', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/456'] )
      end

      it "should parse a DOI containing puncutation" do
        uris = URI::DOI.from_text('10.123/4.5+6%7: But then there were', source:'foo')
        expect(uris).to eq( ['http://dx.doi.org/10.123/4.5+6%7'] )
      end

      it "should return nil when a DOI could not be parsed" do
        expect( URI::DOI.from_text('some text without a DOI', source:'foo') ).to be_nil
      end

      it "should not match some similar doi URLs" do
        expect( URI::DOI.from_text('x10.123/4567.890 ', source:'foo') ).to be_nil
      end

    end

    describe '#full_uri' do

      it "should return the full uri" do
        uri = URI::DOI.new('10.123/456', source:'test')
        expect( uri.full_uri ).to eq('http://dx.doi.org/10.123/456')
      end

    end

    describe '#doi' do

      it "should return the doi" do
        uri = URI::DOI.new('10.123/456', source:'test')
        expect( uri.doi ).to eq('10.123/456')
      end

    end

    describe '#prefix' do

      it "should return the doi prefix" do
        uri = URI::DOI.new('10.123/456', source:'test')
        expect( uri.prefix ).to eq('10.123')
      end

    end

    describe '#provider' do

      it "should match based on a symbol" do
        uri = URI::DOI.new('10.1371/456', source:'test')
        expect( uri.provider ).to eq(:plos)
      end

      it "should return nil if its not known" do
        uri = URI::DOI.new('10.0000/456', source:'test')
        expect( uri.provider ).to be_nil
      end

    end

  end

end