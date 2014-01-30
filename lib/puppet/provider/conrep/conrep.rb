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
require 'open3'
require 'xml/xslt'
require 'erb'
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
      commands :hprcu => candidate
      foundConrep = true
      break
    end
  end

  if ! foundConrep
    fail "conrep binary not found"
  end 

  # No XML until fetched
  $conrepXml = nil

  # Record of changes made
  $changes = []

  $xsltTemplate = <<EOT
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- IdentityTransform -->
    <xsl:template match="/|@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/hprcu/feature[@feature_id='<%= featureId %>']">
        <feature feature_id='<%= featureId %>' selected_option_id='<%= selectedOptionId %>'  sys_default_option_id='<%= sysDefaultOptionId %>' feature_type='option'>
      <xsl:copy-of select="node()"/>
    </feature>
    </xsl:template>
</xsl:stylesheet>
EOT

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
    # * reads the XML that is output by conrep
    # * gathers a list of the names of the features (i.e. BIOS settings)
    # * for each feature it gathers the possible options, the current and default options

    if $conrepXml.nil?
      self.fetchXml
    end

    $property2FeatureIdMap = {}
    $value2SelectionOptionIdMap = {}
    $propertyName2SysDefaultOptionIdMap = {}
    propertyLookup = {}

    # Set some other properties that don't come from the XML
    propertyLookup[:name] = 'default'
    # Force :ensure = :present because, as per p.46 of 'Puppet Types & Providers':
    #   "properties other than ensure are only *individually* managed when ensure
    #   is set to present and the resource already exists. When a resource state
    #   is absent, Puppet ignores any specified resource property."
    propertyLookup[:ensure] = :present

    # Iterate over features and populate propertyLookup in preparation for creating 
    # a new object with the properties and their values defined
    $conrepXml.elements.each('/Conrep/Section') do |section|
      sectionName = makeValid(section.attributes['name'].text.downcase).to_sym
      $sectionValue[sectionName] = section.text;

    end

    # Return an array containing a single instance of the resource (by definition there 
    # is only only one instance of the BIOS settings per host)
    [ new($sectionValue) ]
  end

  def self.fetchXml
    tempfile = Tempfile.new('puppetconrep')
    tempfile.close
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

  # TODO: Consider renaming to 'generateXml' because I can generate a new XML file rather than munging the conrep.dat file that I got from conrep?
  def modifyXml(property)
    # Referring to the data gathered earlier by self.instances, this function
    # looks up the option_id of the new option value and modifies the XML in
    # conrepXml to reflect the new selection
    newValue = @property_flush[property]

    featureId = $property2FeatureIdMap[property]
    selectedOptionId = $value2SelectionOptionIdMap[property][newValue]
    sysDefaultOptionId = $propertyName2SysDefaultOptionIdMap[property]

    xslt = XML::XSLT.new()
    xslt.xml = $conrepXml
    xslt.xsl = ERB.new($xsltTemplate).result(binding)
    $conrepXml = REXML::Document.new xslt.serve()
  end

  def flush
    # Modify XML setting each of the required settings
    @property_flush.keys.each do |property|
      $conrepXml = modifyXml(property) # See above (call 'generateXml(@property_flush)')?
    end

    # Write modified XML to temp. file and load into BIOS using conrep
    tempfile = Tempfile.new('puppetconrep')
    tempfile.write($conrepXml)
    tempfile.close
    conrep('-l', '-f', tempfile.path)

    # Write to flag file if required
    if @resource[:flagchanges] == :true
      flagfilePath = @resource[:flagfile]
      if @resource[:appendchanges] == :true
        flagfile = File.open(flagfilePath, 'a') # TODO: error-checking
      else 
        flagfile = File.open(flagfilePath, 'w') # TODO: error-checking
      end
      @property_flush.keys.each do |property|
        flagfile.write( sprintf("%s: Changed '%s' to '%s'\n", Time.now, property, @property_flush[property] ))
      end
      flagfile.close
    end

    @property_hash = resource.to_hash
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end
end

# vim:sw=2:ts=2:et: 
