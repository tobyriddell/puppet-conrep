#!/usr/bin/ruby
#
# Use conrep.xml to generate conrep type
#
# Steps:
# 1. Scan XML, extract names of settings, convert into Puppet-friendly form 
#    (i.e. valid property names as per the Puppet grammar, defined in the 
#    Puppet code (see 'param_name' in lib/puppet/parser/grammar.ra, 
#    Ast::Name and Ast::Leaf in lib/puppet/parser/ast/leaf.rb)
# 2. (Optional) Invoke newproperty with each property name and check return 
#    code to confirm that the name is valid - emit helpful message if an 
#    invalid name has been generated or if there is a name clash
# 3. For each property, write to a new file the newproperty definition with 
#    appropriate name, valid and default values for the property

require 'puppet'
require 'rexml/document'
require 'erb'

# Parse command line
begin
  if ! ( ARGV[0].nil? or ARGV[0] == '-' ) # Input
    $stdin.reopen(ARGV[0], "r")
  end
rescue Exception
  STDERR.puts "Failed to open input file: #{$!}"
  raise
end

begin
  if ! ( ARGV[1].nil? or ARGV[1] == '-' ) # Output
    $stdout.reopen(ARGV[1], "w")
  end
rescue Exception
  STDERR.puts "Failed to open output file: #{$!}"
  raise
end

puts <<EOT
# conrep type

Puppet::Type.newtype(:conrep) do
	@doc = "This type/provider uses the conrep binary to modify BIOS settings on HP servers. 

Usage:

  puppet resource conrep

  puppet apply -e 'conrep{\\"default\\": hyperthreading => \\"Disabled\\"}'

Note: the name of the resource is hardcoded to 'default'. This is because each server has only one set of BIOS settings; when represented as a resource they need a name, and 'default' seems like a sensible choice.

The names of the settings supported by BIOS revisions varies. The gen_conrep_type.rb script can be used to regenerate the Puppet type to reflect changes in the setting names:

./gen_conrep_type.rb conrep.xml > lib/puppet/type/conrep.rb

"

	# Type must be ensurable as we must use exists?, because as per p. 46 of 
	# Puppet Types and Providers: properties other than ensure are only 
	# *individually* managed when ensure is set to present and the resource 
	# already exists. When a resource state is absent, Puppet ignores any 
	# specified # resource property.
	ensurable

	newparam(:name, :namevar => true) do
	end

EOT

# Map from (e.g.) 'Hyperthreading' to 'hyperthreading'
# Note that the names of the setters must be 'Puppet-friendly', i.e. valid as per
# grammar.ra in the Puppet source
$map2Valid = {}
def makeValid(invalid)
  if ! $map2Valid.has_key?(invalid)
    # Make into a valid puppet symbol by:
    # 1) Changing to lowercase
    # 2) Removing special characters
    # 3) Prepending 'i' if it starts with digits
    # 4) Removing dots if it ends with dots + numbers
    valid = invalid.downcase.gsub(/[- ()_\/:;,]/,'').sub(/^([0-9]+)/, 'i\1').sub(/\.([0-9]+)$/, '\1')
    $map2Valid[invalid] = valid
  end
  $map2Valid[invalid]
end

$newpropertyTemplate = <<EOT
	newproperty(<%= propertyName %>) do
		newvalues(\"<%= validValues.join('", "') %>\")
	end

EOT

conrepFile = File.open('conrep.xml')
conrepXml = REXML::Document.new conrepFile
#conrepXml = REXML::Document.new $stdin

propertyNameSeen = {}

conrepXml.root.elements.each('/Conrep/Section') do |section| 
#  require 'ruby-debug';debugger

  unless propertyNameSeen[section.attributes['name']]
    propertyNameSeen[section.attributes['name']] = true
  
  	propertyName = ':' + makeValid(section.attributes['name'])
  	validValues = []
  
  	section.elements.each('value') do |value| 
#      puts "\t" + value.attributes['id']
#      puts "\t" + value.text
  		#validValues << ':' + makeValid(value.text)
  
      # Need to figure out how to cope with Section elements that appear more than once, for example:
      #  <Section name="Intel_NIC_DMA_Channels">
      #    <helptext><![CDATA[This setting allows the user to enable Intel NIC DMA Channels.]]></helptext>
      #    <platforms>
      #      <platform>Gen8</platform>
      #    </platforms>
      #    <proc_mans>
      #      <proc_man>Intel</proc_man>
      #    </proc_mans>
      #    <nvram>0x45</nvram>
      #    <value id="0x01">Enabled</value>
      #    <value id="0x00">Disabled</value>
      #    <mask>0x01</mask>
      #  </Section>
      #                                                                                                          
      # And:
      #  <Section name="Intel_NIC_DMA_Channels">
      #    <helptext><![CDATA[]]></helptext>
      #    <romfamilies>
      #      <romfamily>R02</romfamily>
      #    </romfamilies>
      #    <nvram>0x6D</nvram>
      #    <value id="0x01">Enabled</value>
      #    <value id="0x00">Disabled</value>
      #    <mask>0x01</mask>
      #  </Section>
      #  In the case of this BIOS parameter the valid values are the same (i.e. 'Enabled' and 'Disabled'). So in this particular case
      #  all we need to do is confirm whether the Section has been seen previously, and if it has then skip it. 
      #
      #  There may be other parameters  potentially introduced in future this may not be the case. There appear to be discriminators for the parameters, i.e. <platforms> and <romfamilies> and presumably these (or something similar) can be used if this arises in future.
  		validValues << value.text
  	end

	  puts ERB.new($newpropertyTemplate).result(binding)
  end
end

puts <<EOT
end
# vim:sw=2:ts=2:et:
EOT

# vim:sw=2:ts=2:et:
