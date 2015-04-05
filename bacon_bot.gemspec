lib = File.join(File.dirname(__FILE__), 'lib')
$:.unshift lib unless $:.include?(lib)

require 'bacon_bot/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'bacon_bot'
  s.summary     = 'The mighty BaconBot'
  s.description = 'The mighty BaconBot of TeamBacon'
  s.date        = Time.now.to_date.to_s
  s.version     = TeamBacon::Version::STRING
  s.homepage    = 'https://github.com/archSeer/Scarlet/'
  s.license     = 'MIT'

  s.authors = ['TeamBacon']

  s.require_path = 'lib'
  s.executables = Dir.glob('bin/*').map { |s| File.basename(s) }
  s.files = ['Gemfile']
  s.files.concat Dir.glob('{lib,spec}/**/*.{rb}')
  s.files.concat Dir.glob('{plugins}/**/*.{rb}')
  s.files.concat Dir.glob('{data}/**/*')
end
