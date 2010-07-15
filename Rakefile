require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mccraigmccraig-better_serialization"
    gem.summary = %Q{json and zlib serialization for activerecord attributes}
    gem.description = %Q{serialize and deserialize activerecord attributes using json or zlib}
    gem.email = "mccraigmccraig@googlemail.com"
    gem.homepage = "http://github.com/trampoline/better_serialization"
    gem.authors = ["http://github.com/crystalcommerce", "http://github.com/rhburrows", "http://github.com/mccraigmccraig"]
    gem.add_dependency "activerecord", ">= 2.3.8"
    gem.add_development_dependency "rspec", ">= 1.2.8"
    gem.add_development_dependency "sqlite3-ruby", ">= 1.3.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "better_serialization #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
