# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{logslam}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Asim"]
  s.add_dependency "eventmachine"
  s.add_dependency "OptionParser"
  s.add_dependency "highline"
  s.add_dependency "daemons"
  s.date = %q{2010-06-03}
  s.default_executable = %q{logslam}
  s.email = %q{asim@chuhnk.me}
  s.executables = ["logslam"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "lib/logslam.rb",
     "lib/logslam/client.rb",
     "lib/logslam/server.rb",
     "lib/logslam/auth.rb",
     "lib/logslam/tail.rb",
     "lib/logslam/launcher.rb",
     "bin/logslam",
     "test/logslam_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/asim/logslam}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = "huh?"
  s.test_files = [
    "test/test_helper.rb",
     "test/logslam_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end
