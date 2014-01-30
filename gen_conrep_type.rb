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

  puppet apply -e 'conrep{"default": hyperthreading => "Disabled"}'

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

	newparam(:flagchanges) do
		newvalues(:true, :false)
		defaultto(:false)
	end

	newparam(:appendchanges) do
		newvalues(:true, :false)
		defaultto(:false)
	end

	newparam(:flagfile) do
		defaultto('/tmp/conrep_changes')
		validate do |path|
			if path.include?('..')
				fail("Path to flagfile must not contains '..'")
			elsif ! ( path.start_with?('/tmp') or path.start_with?('/var/tmp') )
				fail("Path to flagfile must start with '/tmp' or '/var/tmp'")
			end
		end
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

conrepXml.root.elements.each('/Conrep/Section') { |section| 
#  require 'ruby-debug';debugger

	propertyName = ':' + makeValid(section.attributes['name'])
	validValues = []

	section.elements.each('value') { |value| 
#    puts "\t" + value.attributes['id']
#    puts "\t" + value.text
		#validValues << ':' + makeValid(value.text)
		validValues << value.text
	}

	puts ERB.new($newpropertyTemplate).result(binding)
}

puts <<EOT
end
# vim:sw=2:ts=2:et:
EOT

# vim:sw=2:ts=2:et:
