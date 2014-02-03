puppet-conrep
=============

Puppet type &amp; provider to modify BIOS of HP servers using conrep

# Usage

<code>puppet resource conrep</code>

<code>puppet apply -e "conrep{ 'default': intelprocessorturbomode = 'Enabled' }"</code>

In a manifest:

<pre><code>conrep { 'default':
	intelhyperthreading = 'Enabled' 
}</code></pre>

In a class:

<pre><code>
class { 'hyperthreading_on':
	conrep { 'default':
		intelhyperthreading => 'Enabled',
	}
}
</code></pre>

Notes: 

* There's only one collection of BIOS settings per host so there's only one conrep resource per host, and its name is 'default'.
* Property names must conform to the Puppet grammar, as defined in grammar.ra in the Puppet source. Thus 'Intel (R) Hyperthreading Options' is represented by 'intelrhyperthreadingoptions'.
* You may want to run this code (and therefore conrep) only when required - running conrep may interfere with reading the realtime clock from the CMOS (see footnote 4 here: http://mjg59.dreamwidth.org/25686.html)

# Regenerating lib/puppet/type/conrep.rb

It may be necessary to regenerate the Ruby code for the provider if new BIOS settings are added or names change. Here's an example of how to do this:

<pre><code>
./gen_conrep_type.rb /opt/hp/hp-scripting-tools/etc/conrep.xml lib/puppet/type/conrep.rb
</code></pre>

# Dependencies

None

# Design choices

It would be ideal to have a single type for managing BIOS settings for multiple vendors' hardware, and a provider per-vendor to manage resource properties for each particular vendor platform. However, the target is slowly moving: vendors have different names for the same BIOS setting, BIOS revisions can change property names ('name-creep'), new hardware may introduce new settings. Owing to the fact that Puppet doesn't support dynamic property names (see http://grokbase.com/t/gg/puppet-dev/1254htyrr9/how-to-allow-user-specified-property-names-in-provider-code) the names of properties must be pre-defined.

One option would be to map between a setting (e.g. C-states) and a well-defined name, but there are drawbacks to this approach:

 *    what to do it a setting is only supported by HP and not Oracle (for example)
 *    if a setting's name changes the mappings would need updating

These considerations have led me to implement a type & provider for HP hardware. The conrep utility is used under the hood to query and change settings. In order to make life easier in the face of name-creep, the code for the type can be regenerated automatically using XML output from conrep (the provider doesn't contain any hard-coded property names and therefore shouldn't need to be changed so often). This auto-generation may also be needed to support different BIOS revisions that have different names for settings. 

Because property names are auto-generated they can be non-intuitive, for example 'intelrhyperthreadingoptions' instead of plain 'hyperthreading'. As mentioned above, I don't want to have to maintain a static mapping and hence have chosen not to use more friendly names. Running 'puppet resource conrep' on a server is a good way to determine the name of the relevant property.
