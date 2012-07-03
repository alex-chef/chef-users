#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2011-2012, Binary Marbles Trond Arve Nordheim
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_recipe 'ruby-shadow'
Gem.clear_paths

# Update the root password if we have one set.
root = search(:users, 'id:root').first
if root
  root_shell = root[:shell] || '/bin/bash'
  user 'root' do
    shell     root_shell
    password  root[:password]
    action    [:manage]
  end
end

# Add all groups matching the 'active_groups' configuration value, and all the
# users within those groups.
groups = search(:groups)
groups.each do |group|
  if node[:users][:active_groups].include?(group[:id])

    # Create or update the group.
    group group[:id] do
      group_name group[:id]
      gid group[:gid]
      action [:create, :modify, :manage]
    end

    # Add all users within this group.
    search(:users, "groups:#{group[:id]}").each do |user|

      home_dir = user[:home_dir] || "/home/#{user[:id]}"
      user_shell = user[:shell] || '/bin/bash'
      user_primary_group = user[:groups].first.to_s

      # Create the user.
      user user[:id] do
        comment user[:name]
        uid user[:uid]
        gid user_primary_group
        password user[:password]
        home home_dir
        shell user_shell
        action [:create, :manage]
      end

      # Create all the groups associated with this user.
      user[:groups].each do |g|
        group g do
          group_name g.to_s
          gid groups.find { |grp| grp[:id] == g }[:gid]
          members [ user[:id] ]
          append true
          action [:create, :modify, :manage]
        end
      end

      # Create the users home directory.
      directory home_dir do
        owner user[:id]
        group user_primary_group
        mode 0700
        recursive true
      end

      # Create any additional directories for this user, if requested.
      if user[:directories]
        user[:directories].each do |directory_name|
          directory directory_name do
            owner user[:id]
            group user_primary_group
            mode 0755
            recursive true
          end
        end
      end

      # Create the SSH directory for the user.
      directory "#{home_dir}/.ssh" do
        action :create
        owner user[:id]
        group user_primary_group
        mode 0700
      end

      # Install the users SSH key if requested.
      if user[:ssh_keys]
        template "#{home_dir}/.ssh/authorized_keys" do
          source 'authorized_keys.erb'
          owner user[:id]
          group user_primary_group
          mode 0600
          variables(:keys => user[:ssh_keys])
        end
      end

      # Install the users SSH keypairs if requested.
      if user[:ssh_keypairs]
        user[:ssh_keypairs].each do |key_name, keys|

          template "#{home_dir}/.ssh/#{key_name}" do
            source 'ssh_key.erb'
            owner user[:id]
            group user_primary_group
            mode 0600
            variables(:key => keys[:private])
          end

          template "#{home_dir}/.ssh/#{key_name}.pub" do
            source 'ssh_key.erb'
            owner user[:id]
            group user_primary_group
            mode 0600
            variables(:key => keys[:public])
          end
          
        end
      end

      # Install the users SSH config if requested.
      if user[:ssh_config]
        template "#{home_dir}/.ssh/config" do
          source 'ssh_config.erb'
          owner user[:id]
          group user_primary_group
          mode 0600
          variables(:config => user[:ssh_config])
        end
      end

    end

  end
end

# Add all users matching the 'active_users' configuration value.
users = search(:users)
users.each do |user|
  if node[:users][:active_users].include?(user[:id])

    home_dir = user[:home_dir] || "/home/#{user[:id]}"
    user_shell = user[:shell] || '/bin/bash'
    user_primary_group = user[:groups].first.to_s

    # Create the user.
    user user[:id] do
      comment user[:name]
      uid user[:uid]
      gid user_primary_group
      password user[:password]
      home home_dir
      shell user_shell
      action [:create, :manage]
    end

    # Create the users home directory.
    directory home_dir do
      owner user[:id]
      group user_primary_group
      mode 0700
      recursive true
    end

    # Create any additional directories for this user, if requested.
    if user[:directories]
      user[:directories].each do |directory_name|
        directory directory_name do
          owner user[:id]
          group user_primary_group
          mode 0755
          recursive true
        end
      end
    end

    # Create the SSH directory for the user.
    directory "#{home_dir}/.ssh" do
      action :create
      owner user[:id]
      group user_primary_group
      mode 0700
    end

    # Install the users SSH key if requested.
    if user[:ssh_keys]
      template "#{home_dir}/.ssh/authorized_keys" do
        source 'authorized_keys.erb'
        owner user[:id]
        group user_primary_group
        mode 0600
        variables(:keys => user[:ssh_keys])
      end
    end
    
    # Install the users SSH keypairs if requested.
    if user[:ssh_keypairs]
      user[:ssh_keypairs].each do |key_name, keys|

        template "#{home_dir}/.ssh/#{key_name}" do
          source 'ssh_key.erb'
          owner user[:id]
          group user_primary_group
          mode 0600
          variables(:key => keys[:private])
        end

        template "#{home_dir}/.ssh/#{key_name}.pub" do
          source 'ssh_key.erb'
          owner user[:id]
          group user_primary_group
          mode 0600
          variables(:key => keys[:public])
        end
        
      end
    end

    # Install the users SSH config if requested.
    if user[:ssh_config]
      template "#{home_dir}/.ssh/config" do
        source 'ssh_config.erb'
        owner user[:id]
        group user_primary_group
        mode 0600
        variables(:config => user[:ssh_config])
      end
    end

  end
end
