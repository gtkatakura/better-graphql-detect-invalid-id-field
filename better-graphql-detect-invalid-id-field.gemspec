# frozen_string_literal: true
require_relative 'lib/better_graphql/version'

Gem::Specification.new do |spec|
  spec.name = 'better-graphql-detect-invalid-id-field'
  spec.version = BetterGraphQL::VERSION
  spec.authors = ['gtkatakura']
  spec.email = ['gt.katakura@gmail.com']

  spec.summary = 'Detect invalid id field for GraphQL types'
  spec.description = 'Detect invalid id field for GraphQL types by detecting divergent fields between nodes representing the same object'
  spec.homepage = 'http://github.com/gtkatakura/better-graphql-detect-invalid-id-field'
  spec.license = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'http://github.com/gtkatakura/better-graphql-detect-invalid-id-field'
    spec.metadata['changelog_uri'] = 'http://github.com/gtkatakura/better-graphql-detect-invalid-id-field/blob/main/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency('bundler', '~> 1.17')
  spec.add_development_dependency('rake', '~> 10.0')
  spec.add_development_dependency('rspec', '~> 3.0')
  spec.add_development_dependency('rubocop', '~> 1.4')
  spec.add_development_dependency('rubocop-shopify', '~> 1.0.7')

  spec.add_runtime_dependency('graphql', '>= 1.11')
end
