Gem::Specification.new do |s|
  s.name        = 'ring'
  s.version     = '0.0.2'
  s.date        = '2021-12-30'
  s.summary     = "manage several repositories"
  s.description = "A simple tool to manage several GIT repositories"
  s.authors     = ["miko53"]
  s.email       = 'miko53@free.fr'
  s.files       = ["lib/ring_config.rb", "lib/log.rb", "lib/parse_option.rb", "lib/process.rb", "lib/ring_core.rb", "lib/ring_scm.rb" ,"LICENSE.txt", "README.md" ]
  s.executables << 'ring'
  s.homepage    = 'https://github.com/miko53/ring'
  s.license     = 'BSD-3-Clause'
end
