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

count = 0
docker = node[:deploy][:docker]
docker.each do |d|

  machineType = d[:machineType]
  dockerImage = d[:dockerImage]
  dockerImageTag = d[:dockerImageTag]
  dockerRegistry = d[:dockerRegistry]
  dockerEnvironment = d[:dockerEnvironment]
  dockerPort = d[:dockerPort]
  dockerMemory = d[:dockerMemory]
  dockerCPUShares =  (d[:dockerCPUShares]).to_i
  imageToPull = "#{dockerRegistry}/#{dockerImage}:#{dockerImageTag}"

  Chef::Log.info("dockerImage = " + dockerImage)
  Chef::Log.info("dockerImageTag = " + dockerImageTag)
  Chef::Log.info("dockerRegistry = " + dockerRegistry)
  Chef::Log.info("dockerEnvironment = " + dockerEnvironment)
  Chef::Log.info("dockerPort = " + dockerPort)
  Chef::Log.info("dockerMemory = " + dockerMemory)
  Chef::Log.info("dockerCPUShares = " + dockerCPUShares.to_s)

  Chef::Log.info("imageToPull = " + imageToPull)

  resource = dockerImage + count.to_s

  docker_image dockerImage do
  action :pull
    registry dockerRegistry
    tag dockerImageTag
    notifies :redeploy, "docker_container[#{resource}]", :immediately
end

#see https://supermarket.chef.io/cookbooks/docker for all options here
  docker_container resource do
    action :run
    detach true
    container_name resource
    image imageToPull
    port dockerPort
    env dockerEnvironment
    cpu_shares dockerCPUShares
    memory dockerMemory
  restart 'always'
end

  count = count + 1

end


