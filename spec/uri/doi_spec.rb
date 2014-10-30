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

module RichCitationsProcessor

  RSpec.describe RichCitationsProcessor::URI::DOI do

    describe '#matches?' do

      it "should match with symbols" do
        expect( URI::DOI.matches?('absolutely anything', type: :doi) ).to be_truthy
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