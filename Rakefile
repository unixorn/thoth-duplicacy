task :default => [:usage]
task :help => [:usage]
task :clean => [:purge]
task :build => [:build_container]

CONTAINER_NAME = 'unixorn/thoth-duplicacy'
PROCESSOR=`uname -m`.strip()
TIMESTAMP=`date +%Y-%m-%d-%H-%M-%S`.strip()

task :usage do
  puts 'Usage:'
  puts
  puts 'rake buildx      Create a multi-arch container and push to dockerhub'
  puts 'rake clean:      Clean up after building'
  puts
end

# Tasks

task :purge do
  sh %{ rm -fr tmp }
end

desc 'Use buildx to make a multi-arch container'
task :buildx do
  puts "Building #{CONTAINER_NAME}"
  sh %{ docker buildx build --platform linux/arm/v7,linux/amd64,linux/arm64 --push -t #{CONTAINER_NAME} .}
  sh %{ docker pull #{CONTAINER_NAME} }
end
