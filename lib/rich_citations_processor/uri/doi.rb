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

require 'yaml'

module RichCitationsProcessor
  module URI

    class DOI < Base

      def self.matches?(identifier, type:)
        type == :doi
      end

      def self.from_uri(url, **attributes)
        match = DOI_URL_REGEX.match(url)
        match && new(match['doi'], **attributes)
      end

      # Returns an array of URIs
      def self.from_text(text, **attributes)
        matches = DOI_TEXT_REGEX.all_matches(text)
        matches && matches.map do |match| new( match['doi'], **attributes) end
      end

      def doi
        identifier
      end

      def full_uri
        URI_PREFIX + doi
      end

      def prefix
        doi.split('/',2).first
      end

      def provider
        PREFIX_PROVIDER_MAP[prefix]
      end

      private

      # convert the file of provider -> prefix to a prefix->provider lookup
      def self.load_provider_prefixes
        filename = RichCitationsProcessor.config.doi_providers
        provider_prefixes = YAML.load_file(filename)

        provider_prefixes.flat_map do |provider, prefixes|
          provider = provider.to_sym
          prefixes.map do |prefix|
            [prefix, provider]
          end
        end.to_h
      end

      URI_PREFIX       = 'http://dx.doi.org/'

      DOI_PREFIX_CHAR  = %q{[^\/[[:space:]]]}
      DOI_CHAR         = %q{[^[[:space:]]'"]}
      DOI_END_CHAR     = NOT_PUNCT_OR_SPACE

      # For extracting DOIs from text we have to be stricter than the DOI spec which
      # allows spaces and trailing punctuation
      DOI_TEXT_REGEX = /
                         ( \A | \s | #{PUNCT} | #{Regexp.escape(URI_PREFIX)} )  # a DOI must begin with whitespace, punctuation or a URI
                         (?<doi>
                           10\.                         # All DOIs start with '10.'
                           #{DOI_PREFIX_CHAR}+          # The prefix is anything without a slash
                           \/                           # At least one slash
                           #{DOI_CHAR}*                 # Any character is acceptable in a DOI
                           #{DOI_END_CHAR}              # Don't end with punctuation or white space
                          )
                       /iox

      # For testing a string that is a complete DOI URL we can use a more relaxed regex
      DOI_URL_REGEX =/\A
                      #{Regexp.escape(URI_PREFIX)}   # URL Prefix
                      (?<doi>
                        10\.                         # All DOIs start with '10.'
                        [^\/]+                       # The prefix is anything without a slash
                        \/                           # At least one slash
                        .+                           # Any character is acceptable in a DOI
                      )
                      \z /iox

      PREFIX_PROVIDER_MAP = load_provider_prefixes

    end
  end
end