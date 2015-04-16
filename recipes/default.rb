#
# Cookbook Name:: dockerdeploy
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "docker"
include_recipe "apt"
require 'json'


#note this is just pulling latest, you can pull a tag, but I opened
#https://github.com/bflad/chef-docker/issues/300 about specifying that tag
#in docker_container

docker_image 'docker-hello' do
  action :pull
  registry 'docker.otenv.com'
  tag 'latest'
  notifies :redeploy, 'docker_container[docker-hello]', :immediately
end


#see https://supermarket.chef.io/cookbooks/docker for all options here
docker_container 'docker-hello' do
  # Other attributes
  action :run
  detach true
  image 'docker.otenv.com/docker-hello'
  port '8080:8080'
  restart 'always'
end
