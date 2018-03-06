# -*- encoding: utf-8 -*-
# stub: govuk-registers-api-client 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "govuk-registers-api-client".freeze
  s.version = File.read('.version').chomp

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["GOV.UK Registers Team (Government Digital Service)".freeze]
  s.date = "2017-11-06"
  s.email = "registers ~@nospam@~ digital.cabinet-office.gov.uk".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "lib/register_client_manager.rb".freeze]
  s.homepage = "https://github.com/openregister/govuk-registers-api-client".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Client library for GOV.UK Registers".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>.freeze, ["~> 2"])
    else
      s.add_dependency(%q<rest-client>.freeze, ["~> 2"])
    end
  else
    s.add_dependency(%q<rest-client>.freeze, ["~> 2"])
  end
end
