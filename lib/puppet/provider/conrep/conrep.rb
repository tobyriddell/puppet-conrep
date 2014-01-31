# conrep provider
#
# require 'ruby-debug';debugger
#
# Puppet.debug('foo')
#
# set_trace_func proc { |event, file, line, id, binding, classname|
#   printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
# }
#
# $x = inline_template("<%= require 'ruby-debug';debugger; puts 'foo' %>")
#
# require 'ruby-debug';
# Debugger.start(:post_mortem => true)

require 'puppet'
require 'rexml/document'
#require 'open3'
#require 'xml/xslt'
#require 'erb'
require 'tempfile'

# Next: read conrep documentation to determine what form the input XML must take when making changes
# Full output from conrep (conrep.dat) looks like:
# <Conrep version="3.50" originating_platform="ProLiant DL380p Gen8" originating_family="P70" originating_romdate="03/01/2013" originating_processor_manufacturer="Intel">
#   <Section name="IMD_...">...</Section>
#   <Section name="Intel_Processor_Turbo_Mode" ...">Enabled</Section>
#   .
#   .
#   .
# </Conrep>
#
# 1. Does this work when the XML only contains the settings that we want to change? E.g. just Intel_Processor_Turbo_Mode
# 2. Does this work without the "helptext" parameter?
#
# Answer: this works:
# <?xml version="1.0" encoding="UTF-8"?>
# <Conrep>
#   <Section name="Intel_Hyperthreading">Disabled</Section>
#   <Section name="Intel_Processor_Turbo_Mode">Disabled</Section>
# </Conrep>

Puppet::Type.type(:conrep).provide(:conrep) do
  # Look for conrep binary
  foundConrep = false
  ['/usr/bin/conrep', '/sbin/hp-conrep', '/home/toby/Dev/Puppet/puppet-conrep/fakeconrep'].each do |candidate|
    if File.exists?(candidate)
      commands :conrep => candidate
      foundConrep = true
      break
    end
  end

#  # Look for conrep config. file (conrep.xml)
#  foundConrepConfigXml = false
#  ['/opt/hp/hp-scripting/etc/conrep.xml'].each do |candidate|
#    if File.exists?(candidate)
#      $conrepConfigXml = candidate
#      foundConrepConfigXml = true
#      break
#    end
#  end
#
#  if ! foundConrepConfigXml
#    fail "conrep XML config. file (conrep.xml) not found"
#  end 

  # No XML until fetched
  $conrepXml = nil

  # Record of changes made
  $changes = []

  $validSectionName2RealSectionName = {}

  # This is a modified version of mk_resource_methods from provider.rb
  def self.my_mk_resource_methods
    [resource_type.validproperties, resource_type.parameters].flatten.each do |attr|
      if attr.class != Symbol
        attr = attr.intern
      end
      next if attr == :name
      define_method(attr) do
        @property_hash[attr] || :absent
      end

      define_method(attr.to_s + "=") do |val|
        @property_flush[attr] = val.to_s
      end
    end
  end

  my_mk_resource_methods

  # Map from (e.g.) 'Intel(R) Hyperthreading Options' to 'intelrhyperthreadingoptions'
  # Note that the names of setter methods must be 'Puppet-friendly', i.e. valid as per 
  # grammar.ra in the Puppet source
  $map2Valid = {} 
  def self.makeValid(invalid)
    if ! $map2Valid.has_key?(invalid)
      # Make into a valid puppet symbol by:
      # 1) Removing special characters
      # 2) Prepending 'i' if it starts with digits
      # 3) Removing dots if it ends with dots + numbers
      valid = invalid.gsub(/[- ()_\/:;,]/,'').sub(/^([0-9]+)/, 'i\1').sub(/\.([0-9]+)$/, '\1')
      $map2Valid[invalid] = valid
    end
    $map2Valid[invalid]
  end

  def exists?
    # Must return 'true' here because as per p.46 of 'Puppet Types & Providers':
    #   "properties other than ensure are only *individually* managed when ensure
    #   is set to present and the resource already exists. When a resource state
    #   is absent, Puppet ignores any specified resource property."
    true # Equivalent to: @property_hash[:ensure] == :present, because we 
         # force {:ensure => :present} in self.instances
  end

  def self.instances
    # This method does several things:
    # * reads the XML that is output by conrep (conrep.dat)
    # * gathers a list of the names of the features (i.e. BIOS settings)
    # * for each feature it gathers the possible options, the current and default options

    if $conrepXml.nil?
      self.fetchXml
    end

    propertyLookup = {}

    # Set some other properties that don't come from the XML
    propertyLookup[:name] = 'default'
    # Force :ensure = :present because, as per p.46 of 'Puppet Types & Providers':
    #   "properties other than ensure are only *individually* managed when ensure
    #   is set to present and the resource already exists. When a resource state
    #   is absent, Puppet ignores any specified resource property."
    propertyLookup[:ensure] = :present

    # Iterate over sections and populate propertyLookup in preparation for creating 
    # a new object with section names and values defined
    $conrepXml.elements.each('/Conrep/Section') do |section|
      # How do we cope with XML elements which don't represent tunables, for example:
      #   <Section name="IMD_ServerName" helptext="Asset tag string as entered in RBSU">
      #     <Line0>
      #       </Line0>
      #   </Section>
      # Solution: check section.text and if it consists of whitespace then skip it.
      if section.text =~ /\s+/
        # Skip this Section
      else
        sectionName = makeValid(section.attributes['name'].downcase).to_sym

        # Save the real section name to re-use later when generating the XML
        $validSectionName2RealSectionName[sectionName] = section.attributes['name']

        propertyLookup[sectionName] = section.text;
      end
    end

    # Return an array containing a single instance of the resource (by definition there 
    # is only only one instance of the BIOS settings per host)
    [ new(propertyLookup) ]
  end

  def self.fetchXml
    tempfile = Tempfile.new('puppetconrep')
    tempfile.close
#    conrep('-s', '-x', conrepConfigXml, '-f', tempfile.path)
    conrep('-s', '-f', tempfile.path)

    conrepFileHandle = File.open(tempfile.path, 'r');
    $conrepXml = REXML::Document.new conrepFileHandle.read()
    conrepFileHandle.close
  end

  def self.prefetch(resources)
    conreps = instances
    resources.keys.each do |name|
      if provider = instances.find { |inst| inst.name == name }
        resources[name].provider = provider
      end
    end
  end

  def flush
    # Generate XML
    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Conrep>\n"
    property_flush.each do |property, value|
      xml += "<Section name=\"#{$validSectionName2RealSectionName[property]}\">#{value}</Section>\n"
    end
    xml += "</Conrep>"

    # Write modified XML to temp. file and load into BIOS using conrep
    tempfile = Tempfile.new('puppetconrep')
    tempfile.write(xml)
    tempfile.close
#    conrep('-l', '-x', conrepConfigXml , '-f', tempfile.path)
    conrep('-l', '-f', tempfile.path)

    @property_hash = resource.to_hash
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end
end

# vim:sw=2:ts=2:et: 
