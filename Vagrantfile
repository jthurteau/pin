# -*- mode: ruby -*-
# vi: set ft=ruby :

##
# find the podvan script, an external must be used for install/update
van_order = ['src/install/tm', 'podvan/tm', '../tm/tm']
van_order.each {|v| require_relative v if !defined?(Tm) && File.exist?("#{v}.rb")}
raise 'Unable to build LDE. Vagrant Pod VM tools unavailable.' if !defined?(Tm)

##
# this lighter sandbox build can replace Vagrantfile for public distributions
# use it for Ubuntu or Alpine/Podman setups
app_name = Tm::autoname()
web_port = 8080
allow_outside_http = false
authorize_vm = true
tm_config = {
  project: app_name,
  manual_provisioners: [ #[name, file, [script, params]]
    ['reconfigure', 'reconfigure-nginx', ['@build_path']],
     'logs',
     'list',
    'stop',
    #['inject', [app_name]],
    'clean',
    ['start', 'php-fpm/start', [app_name]],
    ['restart', 'php-fpm/start', [app_name, '@build_path']],
    ['container', 'php-fpm/dev-container', [app_name, '@build_path']],
    ['static', 'dev-static', []],
    ['dev', ['@build_path']],
    ['auth', ['@build_path']],
  ],
  auto_provisioners: [
    ['dependencies', 'podvm-dependencies', [app_name, '@build_path']],
    #['temp'],
    ['updates', 'update'],
    ['auto-container', 'php-fpm/dev-container', [app_name, '@build_path']],
    ['deploy', 'app-deploy', []],
  ],
  reload_provisioners: [
    ['reload-restart', 'php-fpm/restart', [app_name, '@build_path']],
  ],
  shared_sources:[
    :main, #['.', '/vagrant'],
    [ '../saf-php7', '/opt/application/vendor/Saf'], #TODO use git from the Dockerfile to deploy this framework directly to the container for non-local-dev
  ],
  authorize_vm: authorize_vm,
}

Vagrant.configure('2') do |config|

  Tm::init(tm_config)
  config.vm.define "#{Tm::project()}-pod" do |pod|
    config.vm.box = Tm::platform() #TODO move into the vbox provider loop?
    Tm::network(config.vm, :web, web_port, allow_outside_http) #TODO move into inso the vbox provider loop?
    Tm::share_sources(config.vm) #TODO move into the vbox provider loop?
    if Vagrant.has_plugin?("vagrant-vbguest")
      config.vbguest.auto_update = false
    end
    config.vm.provider 'virtualbox' do |v|
      Tm::provision(v, config.vm)
    end
  end

end