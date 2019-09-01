task :default => [:usage]
task :help => [:usage]
task :clean => [:purge]
task :build => [:build_container]

CONTAINER_NAME = 'unixorn/thoth-duplicacy'
PROCESSOR=`uname -m`

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
  sh %{ docker-compose build }
  sh %{ docker tag thoth-duplicacy_thoth-duplicacy #{CONTAINER_NAME}:#{PROCESSOR} }
  sh %{ docker push #{CONTAINER_NAME}:#{PROCESSOR} }
end

task :purge do
  sh %{ rm -fr tmp }
end

desc 'Use buildx to make a multi-arch container'
task :buildx do
  puts "Building #{CONTAINER_NAME}"
  sh %{ docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64 --push -t #{CONTAINER_NAME} .}
  sh %{ docker pull #{CONTAINER_NAME} }
  sh %{ docker push #{CONTAINER_NAME} }
end
