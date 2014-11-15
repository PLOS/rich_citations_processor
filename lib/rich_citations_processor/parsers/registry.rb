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
  module Parsers

    class Registry

      class << self

        def lookup(mime_type)
          load_classes unless @@classes_loaded
          @@classes.find do |klass| klass.mime_types.include?(mime_type) end
        end

        def add(resolver_class)
          raise "Cannot register #{resolver_class}}, classes alrady loaded."if  @@classes_loaded
          @@classes << resolver_class
        end

        private

        # Load all the files in this directory to populate the Registry
        def load_classes
          return @@classes if @@classes_loaded

          path = File.join( File.dirname(__FILE__), '*.rb')
          Dir[path].each do |file|
            ActiveSupport::Dependencies.require_or_load(file)
          end
          @@classes_loaded = true

          @@classes
        end

        def prioritize_classes(classes)
          classes = classes.reject do |c| c.abstract? end
          classes =  classes.sort! do |a,b|
                                      v = a.priority <=> b.priority
                                      v==0 ? a.name <=> b.name : v
                                   end

          classes
        end

        @@classes = []
        @@classes_loaded = false

      end

    end
  end
end



