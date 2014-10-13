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

    class Author < Base
      attr_accessor :given
      attr_accessor :family
      attr_accessor :literal
      attr_accessor :email
      attr_accessor :affiliation

      def given=(value)
        @given   = value.presence
        @literal = nil if value.present?
      end

      def family=(value)
        @family   = value.presence
        @literal = nil if value.present?
      end

      def literal=(value)
        @literal   = value.presence
        @given = @family = nil if value.present?
      end

      def indented_inspect(indent='')
        if literal
          result = literal
        elsif family.present? || given.present?
          result = [family, given].compact.join(', ')
        else
          result = '<not provided>'
        end
        result = result + " (#{email})" if email.present?
        result = result + " (#{affiliation})" if affiliation.present?

        "Author: " + result
      end
      alias :inspect :indented_inspect

    end
  end
end