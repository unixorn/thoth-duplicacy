task :default => [:usage]
task :help => [:usage]
# task :clean => [:purge_dehydrated, :purge_tmp]
task :build => [:build_container]

CONTAINER_NAME = 'unixorn/thoth-duplicacy'

task :usage do
  puts 'Usage:'
  puts
  puts 'rake build:      Create the container for docker-compose'
  puts 'rake buildx      Create a multi-arch container and push to dockerhub'
  puts 'rake clean:      Clean up after building'
  puts
end

# Tasks

desc 'build container'
task :build_container do
  sh %{ time docker-compose build }
end

task :slurp_source do
  sh %{ mkdir -p tmp }
  sh %{ cd tmp/src && git clone https://github.com/jeffaco/duplicacy-util.git || echo }
  sh %{ echo GOPATH=#{ENV['PWD']}/tmp}
  sh %{ GOPATH=#{ENV['PWD']}/tmp go get github.com/gilbertchen/duplicacy/duplicacy }
  sh %{ GOPATH=#{ENV['PWD']}/tmp go get github.com/djherbis/times }
  sh %{ GOPATH=#{ENV['PWD']}/tmp go get github.com/mitchellh/go-homedir }
  sh %{ GOPATH=#{ENV['PWD']}/tmp go get github.com/spf13/viper }
  sh %{ GOPATH=#{ENV['PWD']}/tmp go get github.com/theckman/go-flock }
  sh %{ GOPATH=#{ENV['PWD']}/tmp go get gopkg.in/gomail.v2 }
end

task :purge do
  sh %{ rm -fr tmp }
end

desc 'try buildx'
task :buildx => [:slurp_source] do
  puts "Building #{CONTAINER_NAME}"
  sh %{ docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64 --push -t #{CONTAINER_NAME} .}
  sh %{ docker pull #{CONTAINER_NAME} }
end
