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

module RichCitationsProcessor
  module URIResolvers

    class Registry

      class << self

        def add(resolver_class)
          # These aren't concrete classes
          return if [Individual].include?(resolver_class)

          @@classes << resolver_class
        end

        def resolvers(references:, paper:)
          resolver_classes.map { |klass|
            klass.new(references:references, paper:paper)
          }
        end

        def resolver_classes
          load unless @@classes_loaded
          @@classes
        end

        # Load all the files in this directory to populate the Registry
        def load
          return if @@classes_loaded
          path = File.join( File.dirname(__FILE__), '*.rb')
          Dir[path].each do |file|
            ActiveSupport::Dependencies.require_or_load(file)
          end
          @@classes_loaded = true
        end

        private

        @@classes = []
        @@classes_loaded = false

      end

    end
  end
end



