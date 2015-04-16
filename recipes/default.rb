#
# Cookbook Name:: dockerdeploy
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "docker"
include_recipe "aws"
include_recipe "apt"
include_recipe "otuser"
require 'json'

qa_mode = (node[:config][:qa_mode]).to_i
machineType = node[:deploy][:machineType]

environment = node.chef_environment
Chef::Log.info('Node: ' + node.name + ' is running this environment: ' + environment)


Chef::Log.info("qa_mode = " + qa_mode.to_s)

aws = Chef::EncryptedDataBagItem.load("aws", "main")

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
