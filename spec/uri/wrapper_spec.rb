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
  module URI

    RSpec.describe Wrapper do

      describe "::new" do

        it "should create an appropriate instance" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test')
          expect( instance ).to have_attributes(uri:uri, source:'test', metadata:{} )
        end

        it "should create an appropriate instance with metadata" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', more:'sample')
          expect( instance ).to have_attributes(uri:uri, source:'test', metadata: {more:'sample'} )
        end

      end

      describe "atrributes" do

        it "should forward attribues to uri" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test')

          expect(instance.full_uri).to eq('uri://namespace/1')
          expect(instance.to_uri  ).to eq('uri://namespace/1')
          expect(instance.as_json ).to eq('uri://namespace/1')
        end

        it "should read metadata as attributes" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', more:'sample', other:99)

          expect(instance.more ).to eq('sample')
          expect(instance.other).to eq(99)
        end

        it "should delegate metadata attributes" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', more:'sample', other:99)

          expect(instance.identifier ).to eq('1')
        end

        it "should delegate #class" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', more:'sample')

          expect(instance.class).to be(TestURI)
        end

      end

      describe "comparison" do

        it "should compare a wrapper to a uri" do
          uri1 = TestURI.new('1')
          uri2 = TestURI.new('1')
          wrapper = URI::Wrapper.new(uri1, source:'test')

          expect(wrapper == uri2).to be_truthy
        end

        it "should compare a uri to a wrapper" do
          uri1 = TestURI.new('1')
          uri2 = TestURI.new('1')
          wrapper = URI::Wrapper.new(uri1, source:'test')

          expect(uri2 == wrapper).to be_truthy
        end

        it "should compare two wrappers" do
          uri1 = TestURI.new('1')
          uri2 = TestURI.new('1')
          wrapper1 = URI::Wrapper.new(uri1, source:'test1')
          wrapper2 = URI::Wrapper.new(uri2, source:'test2')

          expect(wrapper1 == wrapper2).to be_truthy
        end

      end

      describe '#with_metadata' do

        it "should just return itself" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', more:'sample')
          new = instance.with_metadata

          expect(new).to be(instance)
        end

        it "should take an optional source" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', more:'sample')

          new = instance.with_metadata(source:'bar')

          expect(new.source).to eq('bar')
        end

        it "should merge metadata" do
          uri = TestURI.new('1')
          instance = URI::Wrapper.new( uri, source:'test', field1:'1-1', field2:'2-1')

          new = instance.with_metadata( field2:'2-2', field3:'3-2')

          expect(new.metadata).to eq(field1:'1-1', field2:'2-2', field3:'3-2')
        end

      end

      describe "#inspect" do

        it "should inspect an instance with no extended data" do
          uri = TestURI.new('some-identifier')
          instance = URI::Wrapper.new( uri, source:'base')

          expect(instance.inspect).to eq('[base] uri://namespace/some-identifier')
        end

        it "should inspect an instance with extended data" do
          uri = TestURI.new('some-identifier')
          instance = URI::Wrapper.new( uri, source:'base', more:'sample', score:2)

          expect(instance.inspect).to eq('[base] uri://namespace/some-identifier [more:sample;score:2]')
        end

        it "should inspect extended data with nil values" do
          uri = TestURI.new('some-identifier')
          instance = URI::Wrapper.new( uri, source:'base', more:nil)

          expect(instance.inspect).to eq('[base] uri://namespace/some-identifier [more:nil]')
        end

      end

    end
  end
end