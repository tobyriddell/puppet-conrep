# hprcu type

Puppet::Type.newtype(:hprcu) do
	@doc = "" # TODO

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
    defaultto('/tmp/hprcu_changes')
    validate do |path|
      if path.include?('..')
        fail("Path to flagfile must not contains '..'")
      elsif ! ( path.start_with?('/tmp') or path.start_with?('/var/tmp') )
        fail("Path to flagfile must start with '/tmp' or '/var/tmp'")
      end
    end
  end

	newproperty(:embeddedserialport) do
		newvalues("COM 1; IRQ4; IO: 3F8h-3FFh", "COM 2; IRQ3; IO: 2F8h-2FFh", "COM 3; IRQ5; IO: 3E8h-3EFh", "Disabled")
	end

	newproperty(:virtualserialport) do
		newvalues("COM 1; IRQ4; IO: 3F8h-3FFh", "COM 2; IRQ3; IO: 2F8h-2FFh", "COM 3; IRQ5; IO: 3E8h-3EFh", "Disabled")
	end

	newproperty(:noexecutememoryprotection) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelrhyperthreadingoptions) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelrturboboosttechnology) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:thermalconfiguration) do
		newvalues("Optimal Cooling", "Increased Cooling", "Maximum Cooling")
	end

end
# vim:sw=2:ts=2:et:
