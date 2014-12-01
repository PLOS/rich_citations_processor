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

# Note: We don't validate ISBN checksums in any way
#   (except for recalculating them when converting to ISBN13)

module RichCitationsProcessor
  module URI

    class ISBN < Base

      def self.types
        [:isbn]
      end

      def self.priority
        200
      end

      def self.from_uri(url, **attributes)
        match = URL_REGEX.match(url)
        match && new( match['isbn'], **attributes)
      end

      # Returns an array of URIs
      def self.from_text(text, **attributes)
        matches = TEXT_REGEX.all_matches(text)
        matches && matches.map do |match| new( match['isbn'] , **attributes) end
      end

      def raw_isbn
        identifier
      end

      def full_uri
        URI_PREFIX + isbn_13
      end

      def isbn_10
        isbn =clean_isbn
        return isbn if isbn.length==10
        return isbn unless isbn[0..2]== ISBN_13_PREFIX

        isbn = isbn[3..-2] # Remove prefix and check digit

        # calculate the checksum
        chars = isbn.each_char.map(&:to_i)
        sump  = chars.each_with_index.inject(0) { |sum, (n, i)| sum + n*(10-i) }
        chk   = (11 - sump % 11) % 11
        chk   = chk == 10 ? 'X' : chk.to_s
        isbn + chk
      end

      def isbn_13
        isbn =clean_isbn
        return isbn if isbn.length==13
        isbn = ISBN_13_PREFIX + isbn[0..-2] # Remove check digit for now

        # calculate the checksum
        chars = isbn.each_char.map(&:to_i)
        sump  = chars.each_with_index.inject(0) { |sum, (n, i)| sum + n* (i.even? ? 1 : 3) }
        chk   = (10 - sump % 10) % 10
        isbn + chk.to_s
      end

      def ==(other)
        super || ( other.is_a?(ISBN) && full_compare(other) )
      end

      protected

      def full_compare(other)
        clean_isbn == other.clean_isbn ||
        isbn_13    == other.isbn_13    ||
        isbn_10    == other.isbn_10
      end

      def clean_isbn
        raw_isbn.strip.upcase.gsub(/[^0-9X]/,'')
      end

      private

      ISBN_13_PREFIX = '978'

      # 10 or 13 digits with optional hyphens
      ISBN_REGEX = '(\d{3}\-?)?(\d\-?){9}(\d|X)'

      URI_PREFIX       = 'urn:isbn:'
      URI_PREFIX_REGEX = Regexp.escape(URI_PREFIX)

      TEXT_REGEX     = /
                         ( (#{URI_PREFIX_REGEX} ) | # an ISBN must begin with a URI or 'isbn:'
                           (isbn\s*:\s*) )
                         (?<isbn>                            # followed the the 10 or 13 isbn
                           #{ISBN_REGEX}
                         )
                         ( [[:punct:]] | [[:space:]] | \z ) # And end with punctuation whitespace or end of line
                       /iox

      # For testing a string that is a complete DOI URL we can use a more relaxed regex
      URL_REGEX    = /\A
                      #{URI_PREFIX_REGEX}
                      (?<isbn>
                        #{ISBN_REGEX}
                      )
                      \z /iox

    end
  end
end