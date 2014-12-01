# RichCitationsProcessor
(c) 2014 PLOS Labs

Process input data and convert to Rich Citations JSON

## Installation

Add this line to your application's Gemfile:

    gem 'rich_citations_processor'


## How it works

A source (text document is passed through a series of steps:

1. Parsing: The document is parsed from its source format (For example an XML document conforming to a JATS/NLM DTD)
and turned into a set of internal object representations that closely match the Rich Citations JSON structure.
If you want to support a new import format then you probably just want to write a new parser.

2. Identifier Resolving: Each reference is analyzed to determine a set of candidate URIs that it could resolve to.

3. Metadata Retrieval: Based on the candidate URIs a set of services is called to retrieve additional bibliographic
metadata for each reference. This metadata conforms to the citeproc+json standard but can include additional metadata as needed such as licensing and abstracts.

4. Additionally results are cached for a URI to speed up prcoessing.

## Goals


## Usage

Sample code would be something along the lines of:

```
  jats_xml   = get_jats_or_nlm_document_from_some_service
  parser     = RichCitationsProcessor::Parsers::JATS.new(jats_xml)
  -- or by mime type ---
  parser     = RichCitationsProcessor::Parsers.create('application/jats+xml', jats_xml)

  paper      = parser.parse!

  serializer = RichCitationsProcessor::Serializers::JSON.new(paper)
  -- or by mime type ---
  serializer = RichCitationsProcessor::Serializers.create('application/richcitations+json', paper)

  output     = serializer.serialize

```

TODO: Write better usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rich_citations_processor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
