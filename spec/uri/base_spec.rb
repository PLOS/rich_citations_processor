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

    class Test < Base
      def self.types; [:foo]; end
      def self.priority; 999_999_999; end
      def full_uri; "uri://#{identifier}"; end
      public :identifier
    end

    RSpec.describe Base do

        describe '::new' do

          it "should accept an identifer" do
            uri = URI::Test.new('some-identifier')
            expect(uri.identifier).to eq('some-identifier')
          end

        end

        describe "#inspect" do

          it "should inspect an instance with no extended data" do
            uri = URI::Test.new('some-identifier')
            expect(uri.inspect).to eq('uri://some-identifier')
          end

        end

        describe "with_metadata" do

          it "should return a wrapper" do
            uri = URI::Test.new('some-identifier')
            wrapper = uri.with_metadata(source:'foo')

            expect(wrapper).to be_a_kind_of(Wrapper)
            expect(wrapper.uri).to be(uri)
          end

          it "the wrapper should have a source and metadata" do
            uri = URI::Test.new('some-identifier')
            wrapper = uri.with_metadata(source:'foo', more:'sample')

            expect(wrapper).to have_attributes(source:'foo', metadata:{more:'sample'})
          end

        end

      end

  end
end