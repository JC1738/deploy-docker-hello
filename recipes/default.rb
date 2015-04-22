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
  enabled = d[:enabled]
  imageToPull = "#{dockerRegistry}/#{dockerImage}:#{dockerImageTag}"

  Chef::Log.info("dockerImage = " + dockerImage)
  Chef::Log.info("dockerImageTag = " + dockerImageTag)
  Chef::Log.info("dockerRegistry = " + dockerRegistry)
  Chef::Log.info("dockerEnvironment = " + dockerEnvironment)
  Chef::Log.info("dockerPort = " + dockerPort)
  Chef::Log.info("dockerMemory = " + dockerMemory)
  Chef::Log.info("dockerCPUShares = " + dockerCPUShares.to_s)
  Chef::Log.info("enabled = " + enabled.to_s)


  Chef::Log.info("imageToPull = " + imageToPull)

  resource = dockerImage + count.to_s

  bash resource do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
      sudo docker stop #{resource}
    EOF
    returns [0,1]
    notifies :pull, "docker_image[#{dockerImage}]", :immediately
    notifies :redeploy, "docker_container[#{resource}]", :immediately
    only_if { enabled }
  end


  docker_image dockerImage do
    action :pull
    registry dockerRegistry
    tag dockerImageTag
    #notifies :redeploy, "docker_container[#{resource}]", :immediately
    only_if { enabled }
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
    only_if { enabled }
  end

  count = count + 1

end
