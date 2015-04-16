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


docker_image 'docker-hello' do
  action :pull
  registry 'docker.otenv.com'
  tag 'build-2'
  notifies :redeploy, 'docker_container[docker-hello]', :immediately
end

#see https://supermarket.chef.io/cookbooks/docker for all options here
docker_container 'docker-hello' do
  # Other attributes
  action :run
  detach true
  container_name 'docker-hello'
  image 'docker.otenv.com/docker-hello:build-2'
  port '8080:8080'
  restart 'always'
end
