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
require 'open-uri'


#for health check
package "curl" do
    action :install
end

ipHost = node[:ipaddress]
setToDeploy = node[:deploy][:set]


setToDeploy ||= "all"

Chef::Log.info("ipaddress = " + ipHost)


dockerVersion = node[:docker][:version]
docker = node[:deploy][:docker]

Chef::Log.info("**************************************")
Chef::Log.info("dockerVersion = " + dockerVersion)
Chef::Log.info("setToDeploy = " + setToDeploy)
Chef::Log.info("**************************************")

count = 0
docker.each do |d|

  includeInSet = false
  machineType = d[:machineType]
  dockerImage = d[:dockerImage]
  dockerImageTag = d[:dockerImageTag]
  dockerRegistry = d[:dockerRegistry]
  dockerEnvironment = Array.new(d[:dockerEnvironment])
  dockerPort = d[:dockerPort]
  dockerMemory = d[:dockerMemory]
  dockerVolumes = d[:dockerVolumes]
  dockerCPUShares =  (d[:dockerCPUShares]).to_i
  dockerAdditionalCMDs = d[:dockerAdditionalCMDs]
  deployCheck = d[:deployCheck]
  enabled = d[:enabled]
  imageToPull = "#{dockerRegistry}/#{dockerImage}:#{dockerImageTag}"

  dockerAdditionalCMDs ||= " "


  #allow individual deployments
  if setToDeploy == "all" || machineType == setToDeploy
    includeInSet = true
  end

  dockerEnvironment.push("TASK_HOST=#{ipHost}")

  Chef::Log.info("**************************************")
  Chef::Log.info("machineType = " + machineType)
  Chef::Log.info("dockerImage = " + dockerImage)
  Chef::Log.info("dockerImageTag = " + dockerImageTag)
  Chef::Log.info("dockerRegistry = " + dockerRegistry)
  Chef::Log.info("dockerEnvironment = " + dockerEnvironment.to_s) #array
  Chef::Log.info("dockerPort = " + dockerPort)
  Chef::Log.info("dockerMemory = " + dockerMemory)
  Chef::Log.info("dockerVolumes = " + dockerVolumes.to_s) #array
  Chef::Log.info("dockerCPUShares = " + dockerCPUShares.to_s) #number
  Chef::Log.info("dockerAdditionalCMDs = " + dockerAdditionalCMDs)
  Chef::Log.info("deployCheck = " + deployCheck.to_s) #incase nil
  Chef::Log.info("enabled = " + enabled.to_s)
  Chef::Log.info("includeInSet = " + includeInSet.to_s) #bool
  Chef::Log.info("imageToPull = " + imageToPull)
  Chef::Log.info("**************************************")

  resource = dockerImage + count.to_s

  bash resource do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
      sudo docker stop #{resource}
      sudo docker rm -v #{resource}
      sudo docker pull #{dockerRegistry}/#{dockerImage}:#{dockerImageTag}
    EOF
    returns [0,1]  #if docker already stopped, returns 1, otherwise 0 if successful
    notifies :pull_if_missing, "docker_image[#{dockerImage}]", :immediately
    notifies :redeploy, "docker_container[#{resource}]", :immediately
    notifies :remove, "docker_container[#{resource}]", :immediately
    only_if { includeInSet }
  end


  docker_image dockerImage do
    action :pull_if_missing
    registry dockerRegistry
    tag dockerImageTag
    retry_delay 5
    retries 3
    only_if { enabled && includeInSet }
  end

#see https://supermarket.chef.io/cookbooks/docker for all options here
  docker_container resource do
    action :run
    detach true
    container_name resource
    image imageToPull + dockerAdditionalCMDs
    port dockerPort
    env dockerEnvironment
    cpu_shares dockerCPUShares
    memory dockerMemory
    volume dockerVolumes
    additional_host "docker:#{ipHost}"
    restart 'always'
    retry_delay 5
    retries 3
    only_if { enabled && includeInSet }
  end

  #note, enabled needs to have been run atleast once with true
  docker_container resource do
    action :remove
    only_if { !enabled && includeInSet }
  end


  #doHealthCheck should be condintional on if provide deployCheck
  urlTest = "No check defined"
  if !(deployCheck.nil? || deployCheck.empty?)
    doHealthCheck = true
    urlTest = "http://#{ipHost}#{deployCheck}"
  end


  Chef::Log.info("**************************************")
  Chef::Log.info("Attempting: curl #{urlTest} for #{imageToPull}")
  Chef::Log.info("**************************************")


  ruby_block "#{resource} Test" do
    block do


      open("http://#{ipHost}#{deployCheck}") do |f|
        if f.status[0] != "200"
          raise "Return code was: " + f.status[0]
        end

      end

    end
    retry_delay 5
    retries 3
    action :run
    only_if { includeInSet && doHealthCheck }
  end



  count = count + 1

end
