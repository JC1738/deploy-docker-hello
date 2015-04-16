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
  tag 'latest'
  notifies :redeploy, 'docker_container[docker-hello]', :immediately
end

docker_container 'docker-hello' do
  # Other attributes
  action :run
  detach true
  image 'docker.otenv.com/docker-hello'
  port '8080:8080'
  restart 'always'
end
