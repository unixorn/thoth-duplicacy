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
  sh %{ docker-compose build }
end

desc 'try buildx'
task :buildx do
  puts "Building #{CONTAINER_NAME}"
  sh %{ docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64 --push -t #{CONTAINER_NAME} .}
  sh %{ docker pull #{CONTAINER_NAME} }
end
