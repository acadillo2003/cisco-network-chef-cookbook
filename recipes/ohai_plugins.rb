#
# Cookbook Name:: cisco-cookbook
# Recipe:: ohai_plugins
#
# Copyright 2011-2015, Chef Software, Inc
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

reload_ohai = false

# This is done during the compile phase so new plugins can be used in
# resources later in the run.
node['ohai']['plugins'].each_pair do |source_cookbook, path|
  rd = remote_directory "#{node['ohai']['plugin_path']} for cookbook #{source_cookbook}" do
    path Ohai::Config[:plugin_path].first # use system default plugin path
    cookbook source_cookbook
    source path
    mode '0755' unless platform_family?('windows')
    recursive true
    purge false
    action :nothing
  end

  rd.run_action(:create)
  reload_ohai ||= rd.updated?
end

resource = ohai 'custom_plugins' do
  action :nothing
end

# Reload ohai if the client's plugin_path did not contain
# node['ohai']['plugin_path'], or new plugins were loaded
resource.run_action(:reload) if reload_ohai
