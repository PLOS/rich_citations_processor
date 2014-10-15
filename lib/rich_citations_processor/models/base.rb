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

module RichCitationsProcessor
  module Models

    class Base

      def initialize(**attributes)
        assign_attributes!(**attributes)
      end

      def assign_attributes!(**attributes)
        attributes.each do |name, value|
          setter = "#{name}="
          "testing setter #{setter.inspect}"
          raise ArgumentError.new("Parameter #{name} not supported") unless respond_to?(setter)
          send(setter, value)
        end
      end

      def attribute_names
        public_methods.map do |name|
          match = name.to_s.match(/\A(\w+)=\z/)
          next unless match
          getter = match[1]
          next unless respond_to?(getter)

          getter
        end.compact
      end

      def attribute_values
        attribute_names.map { |name| [name, send(name) ] }.to_h
      end

      def indented_inspect(indent='')
        # Get all the values that have both setters and getters
        values = attribute_values.compact.map do |name, value|
          "#{name.titleize}: #{value.inspect}"
        end

        object_name = self.class.to_s.demodulize.titleize
        object_name + ": " + values.join(', ')
      end
      alias :inspect :indented_inspect

    end
  end
end