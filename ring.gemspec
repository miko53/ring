Gem::Specification.new do |s|
  s.name        = 'ring'
  s.version     = '1.0.0'
  s.date        = '2020-12-29'
  s.summary     = "manage several repositories"
  s.description = "A simple tool to manage several GIT repositories"
  s.authors     = ["miko53"]
  s.email       = 'miko53@free.fr'
  s.files       = ["lib/ring_config.rb", "lib/log.rb", "lib/parse_option.rb", "lib/process.rb", "lib/ring_core.rb" ]
  s.executables << 'ring'
  s.homepage    = 'https://github.com/miko53/ring'
  s.license     = 'BSD-3-Clause License'
end
