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
  puts 'rake build:      Create the container for docker-compose'
  puts 'rake buildx      Create a multi-arch container and push to dockerhub'
  puts 'rake clean:      Clean up after building'
  puts
end

# Tasks

desc 'build container'
task :build_container do
  puts "Building #{CONTAINER_NAME} for #{PROCESSOR}"
  sh %{ docker-compose build }
  sh %{ docker tag thoth-duplicacy_thoth-duplicacy #{CONTAINER_NAME}:#{PROCESSOR} }
  sh %{ docker tag thoth-duplicacy_thoth-duplicacy #{CONTAINER_NAME}:#{PROCESSOR}-#{TIMESTAMP} }
  sh %{ docker push #{CONTAINER_NAME}:#{PROCESSOR} }
  sh %{ docker push #{CONTAINER_NAME}:#{PROCESSOR}-#{TIMESTAMP} }
end

task :purge do
  sh %{ rm -fr tmp }
end

desc 'Use buildx to make a multi-arch container'
task :buildx do
  puts "Building #{CONTAINER_NAME}"
  sh %{ docker buildx build --platform linux/arm/v7,linux/amd64,linux/arm64 --push -t #{CONTAINER_NAME} .}
  sh %{ docker pull #{CONTAINER_NAME} }
  sh %{ docker push #{CONTAINER_NAME} }
end
