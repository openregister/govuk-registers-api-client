require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'

require 'rspec'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--format documentation --colour)
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, 'w') {|f| f << spec.to_ruby }
end

task package: :gemspec

RDoc::Task.new do |rd|
  rd.main = 'README.md'
  rd.rdoc_files.include('README.md', 'lib/**/*.rb')
  rd.rdoc_dir = 'rdoc'
end

desc 'Clear out RDoc and generated packages'
task clean: [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
