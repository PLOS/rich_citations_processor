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

  RSpec.describe URIResolver do

    describe '#resolve!' do

      def create_resolver
        resolver = instance_double(URIResolvers::Base)
        expect(resolver).to receive(:resolve!) {
                              @called_resolvers << resolver
                            }
        resolver
      end

      def create_resolvers
        @called_resolvers = []
        (1..4).map { |i| create_resolver }
      end

      it "should call each resolver in order" do
        paper = Models::CitingPaper.new
        resolvers = create_resolvers

        expect(URIResolvers::Registry).to receive(:resolvers).with(references:paper.references, paper:paper).and_return(resolvers)

        resolver = URIResolver.new(paper)
        resolver.resolve!

        expect(@called_resolvers).to eq(resolvers)
      end

    end

  end

end