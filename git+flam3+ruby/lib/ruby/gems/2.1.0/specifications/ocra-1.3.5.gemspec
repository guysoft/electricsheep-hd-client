# -*- encoding: utf-8 -*-
# stub: ocra 1.3.5 ruby lib

Gem::Specification.new do |s|
  s.name = "ocra"
  s.version = "1.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lars Christensen"]
  s.date = "2015-04-23"
  s.description = "OCRA (One-Click Ruby Application) builds Windows executables from Ruby\nsource code. The executable is a self-extracting, self-running\nexecutable that contains the Ruby interpreter, your source code and\nany additionally needed ruby libraries or DLL."
  s.email = ["larsch@belunktum.dk"]
  s.executables = ["ocra"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "bin/ocra"]
  s.homepage = "https://github.com/larsch/ocra/"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.rubygems_version = "2.2.3"
  s.summary = "OCRA (One-Click Ruby Application) builds Windows executables from Ruby source code"

  s.installed_by_version = "2.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
