## 
# Helps Manage Environment Replication in a Vagrant Pod VM
# https://podman.readthedocs.io/
# https://www.vagrantup.com/docs/
#
# You do not need Ruby on the guest for this module.
# You should not need Ruby installed on the host, 
# aside from the runtime built into Vagrant
# see ../Vagrantfile for how this module is used
#
# Based on earlier work on Mr https://github.com/jthurteau/mr
# Copyright 2022 Troy Hurteau Under GPL-3.0 License
# https://github.com/jthurteau/jthurteau.github.io/blob/main/COPYRIGHT

module Tm
  extend self

  require_relative 'tm/utils'

  ##
  # where Tm runs from and aquires global(for intneral)/external recipes
  # for an "internal" tm project build, my_path and active_path are the same
  @my_path = File.dirname(__FILE__)

  ##
  # base path for the repo
  @base_path = File.dirname(File.dirname(__FILE__))

  ##
  # what VM image Tm should use as a base
  # https://alpinelinux.org/releases/
  # https://app.vagrantup.com/boxes/search?utf8=%E2%9C%93&sort=created&provider=&q=alpine
  # @platform = 'generic/alpine318' # not available 6/30/2023
  @platform = 'generic/alpine315'

  ##
  # default secret generation length
  @secret_length = 16

  ##
  # default characters for secret generation
  @secret_set = '0123456789abcedf'

  ##
  # storage for the local secret
  @secret_file = 'secret.txt'

  ##
  # local secret
  @my_secret = nil

  ##
  # config file path
  @config_path = ''

  ##
  # seed files
  @config_files = []

  ##
  # project name
  @project = 'dev-container'

  ##
  # path to store temp/local project files between environments
  @project_path = nil

  ##
  # vm name
  @vm_name = '[project]_sandbox'

  ##
  # path for install files
  @build_path = 'src/install'

  ##
  # autodetect build_path
  @auto_build_path = true;

  ##
  # path for shell provisioners
  @shell_path = '[build_path]/shell'

  ##
  #
  @sample_token = 'sample.'

  ##
  #
  @local_token = 'local-dev.'

  ##
  # auto running provisioners ('once')
  @auto = []
  
  ##
  # manually running provisioners ('never')
  @manual = []

  ##
  # auto running provisioners ('reload and up')
  @reload = []

  ##
  # local folders to mount into the VM
  @shared = []

  def self.init(config)
    nc = TmUtils::sym_keys(config)
    self._config(nc)
    @base_path = TmUtils::base(caller)
    if (@auto_build_path && @my_path.start_with?(@base_path))
      @build_path = @my_path.slice((@base_path.length + 1)..-1)
    end
    @project_path = "#{@local_token}#{@project}"
    secret_path = "#{@my_path}/#{@project_path}/#{@secret_file}"
    TmUtils::assert_path("#{@my_path}/#{@project_path}")
    authorize_vm = nc.include?(:authorize_vm) && nc[:authorize_vm]
    TmUtils::authorize("#{@my_path}/#{@project_path}") if authorize_vm
    @my_secret = TmUtils::assert_secret(secret_path, @secret_length, @secret_set)
    @vm_name = TmUtils::name_safe(TmUtils::sub(@vm_name,self._vars())) #TODO loop this
    @shell_path = TmUtils::name_safe(TmUtils::sub(@shell_path,self._vars()))
    #TmUtils::trace(@vm_name)
    TmUtils::assert_config_files(@config_files, @config_path, @sample_token)
  end

  def self.project
    @project
  end

  def self.platform
    @platform
  end

  def self.provision(p, vm)
    #p.name = @vm_name if @singleton
    #TmUtils.trace(TmUtils::bind(@auto, self._vars))
    TmUtils::bind(@auto, self._vars).each() {|a| self._add(vm, a, 'once')}
    TmUtils::bind(@manual, self._vars).each() {|m| self._add(vm, m)}
    TmUtils::bind(@reload, self._vars).each() {|a| self._add(vm, a, 'always')}
  end

  def self.path()
    @my_path
  end

  def self.share_sources(vm, s = nil)
    s = @shared if s.nil?
    s = TmUtils::enforce_enumerable(s)
    t = 0
    s.each() do |m|
      m = ['.', '/vagrant'] if m == :main
      l = m.is_a?(Array) ? m[0] : m
      if (m.is_a?(Array) && m.length < 2) 
        r ="/opt/tmp#{t.to_s}"
        t +=1
      else
        r = m[1]
      end
      vm.synced_folder l, r, owner: 'vagrant', group: 'vagrant'
    end
  end

  def self.network(vm, local_port, remote_port, exposed)
    local_port = 80 if local_port == :web
    if (exposed)
      vm.network :forwarded_port, guest: local_port, host: remote_port
    else 
      vm.network :forwarded_port, guest: local_port, host: remote_port, host_ip: '127.0.0.1'
    end
  end

  def self.autoname()
    auto = File.basename(@base_path, '.*')
    return auto.length > 0 ? auto : 'sandbox'
  end

  #################################################################
    private
  #################################################################

  def self._config(config)
    vars = self._vars()
    TmUtils.sym_keys(config).each() {|k,v| self._set(k,v,vars)}
  end

  def self._vars()
    { #NOTE to support :vars binding, longer strings have to precede shorter matches
      'build_path': @build_path,
      'project_path': @project_path,
      'project': @project,
      'secret': @my_secret,
    }
  end

  def self._set(key, value, vars = [])
    case key
    when :project
      @project = TmUtils::name_safe(value)
    when :platform
      @platform = value
    when :manual_provisioners
      @manual = value
    when :auto_provisioners
      @auto = value
    when :reload_provisioners
      @reload = value
    when :auto_build_path
      @auto_build_path = value
    when :build_path
      @build_path = TmUtils::name_safe(value, true)
    when :shell_path
      @shell_path = TmUtils::name_safe(value, true)
    when :config_files
      @config_files = TmUtils::name_safe(value, true)
    when :secret_length
      @secret_length = value #TODO assert integer
    when :secret_set
      @secret_set = value
    when :secret_file
      @secret_file = TmUtils::name_safe(value, true)
    when :config_path
      @config_path = TmUtils::name_safe(value, true)
    when :config_files
      @config_files = value #TODO each
    when :vm_name
      @vm_name = TmUtils::name_safe(TmUtils::sub(value,vars))
      TmUtils::trace(@vm_name)
      TmUtils::shutdown('halting')
    when :sample_token
      @sample_token = TmUtils::name_safe(value)
    when :local_token
      @local_token = TmUtils::name_safe(value)
    when :shared_sources
      @shared = value
    end
  end

  def self._add(vm, params, run_when = 'never')
    params = [params] if params.is_a?(String) && params.length > 0
    return if !params || !params.is_a?(Array) || params.length < 1
    name = params[0]
    file_base = params.length > 1 && params[1].is_a?(String) ? params[1]: name
    arg_short = params.length > 1 && params[1].class.include?(Enumerable) ? 1 : false
    arg_index = params.length > 2 ? 2 : arg_short
    args = arg_index ? params[arg_index] : [@my_secret]
    file = "#{file_base}.sh"
    vm.provision name, type: 'shell', path: "#{@shell_path}/#{file}", args: args, run: run_when
  end
  
end