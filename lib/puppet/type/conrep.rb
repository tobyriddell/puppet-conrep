# conrep type

Puppet::Type.newtype(:conrep) do
	@doc = "This type/provider uses the conrep binary to modify BIOS settings on HP servers. 

Usage:

  puppet resource conrep

  puppet apply -e 'conrep{\"default\": hyperthreading => \"Disabled\"}'

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

	newproperty(:os) do
		newvalues("")
	end

	newproperty(:imdservername) do
		newvalues("")
	end

	newproperty(:imdserverassettag) do
		newvalues("")
	end

	newproperty(:imdserverprimaryos) do
		newvalues("")
	end

	newproperty(:imdservermiscinfo) do
		newvalues("")
	end

	newproperty(:imdadminname) do
		newvalues("")
	end

	newproperty(:imdadminphone) do
		newvalues("")
	end

	newproperty(:imdadminpager) do
		newvalues("")
	end

	newproperty(:imdadminmisc) do
		newvalues("")
	end

	newproperty(:imdservicename) do
		newvalues("")
	end

	newproperty(:imdservicephone) do
		newvalues("")
	end

	newproperty(:imdservicepager) do
		newvalues("")
	end

	newproperty(:imdservicemisc) do
		newvalues("")
	end

	newproperty(:imduserdefinedname) do
		newvalues("")
	end

	newproperty(:imduserdefinedmenu) do
		newvalues("")
	end

	newproperty(:imduserdefinedsubmenu) do
		newvalues("")
	end

	newproperty(:iplorder) do
		newvalues("")
	end

	newproperty(:iplordersize) do
		newvalues("")
	end

	newproperty(:pcidevices) do
		newvalues("")
	end

	newproperty(:controllerorder) do
		newvalues("")
	end

	newproperty(:language) do
		newvalues("")
	end

	newproperty(:systemwol) do
		newvalues("Undefined", "Enabled", "Disabled", "Reserved")
	end

	newproperty(:systemapic) do
		newvalues("Auto Set", "Full Table Mapped", "Full Table", "Disabled")
	end

	newproperty(:systemmouse) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:systemcpuserialnumber) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:systemcoma) do
		newvalues("Undefined", "COM1", "COM2", "COM3", "COM4", "Disabled")
	end

	newproperty(:systemcomairq) do
		newvalues("Undefined", "IRQ1", "IRQ2", "IRQ3", "IRQ4", "IRQ5", "IRQ6", "IRQ7", "IRQ8", "IRQ9", "IRQ10", "IRQ11", "IRQ12", "IRQ13", "IRQ14", "IRQ15")
	end

	newproperty(:systemcomb) do
		newvalues("Undefined", "COM1", "COM2", "COM3", "COM4", "Disabled")
	end

	newproperty(:systemcombirq) do
		newvalues("Undefined", "IRQ1", "IRQ2", "IRQ3", "IRQ4", "IRQ5", "IRQ6", "IRQ7", "IRQ8", "IRQ9", "IRQ10", "IRQ11", "IRQ12", "IRQ13", "IRQ14", "IRQ15")
	end

	newproperty(:systemvirtualserialport) do
		newvalues("Undefined", "COM1", "COM2", "COM3", "COM4", "Disabled")
	end

	newproperty(:systemvirtualserialportirq) do
		newvalues("Undefined", "IRQ1", "IRQ2", "IRQ3", "IRQ4", "IRQ5", "IRQ6", "IRQ7", "IRQ8", "IRQ9", "IRQ10", "IRQ11", "IRQ12", "IRQ13", "IRQ14", "IRQ15")
	end

	newproperty(:systemlpt) do
		newvalues("Undefined", "LPT1", "LPT2", "LPT3", "Disabled")
	end

	newproperty(:systemlptirq) do
		newvalues("Undefined", "IRQ1", "IRQ2", "IRQ3", "IRQ4", "IRQ5", "IRQ6", "IRQ7", "IRQ8", "IRQ9", "IRQ10", "IRQ11", "IRQ12", "IRQ13", "IRQ14", "IRQ15")
	end

	newproperty(:systemlptmode) do
		newvalues("SPP", "ECP", "EPP")
	end

	newproperty(:systemusbcontrol) do
		newvalues("Enabled", "Disabled", "Legacy USB Disabled", "External Ports Disabled")
	end

	newproperty(:systemusbehcicontroller) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:diskettewritecontrol) do
		newvalues("Writes_Enabled", "Writes_Disabled")
	end

	newproperty(:postf1prompt) do
		newvalues("Enabled", "Disabled", "Delayed")
	end

	newproperty(:hyperthreading) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:nmidebugbutton) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:acpipowerbutton) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:cpuperformance) do
		newvalues("Memory", "IO")
	end

	newproperty(:asr) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:asrtimeout) do
		newvalues("2 Minutes", "5 Minutes", "10 Minutes", "15 Minutes", "20 Minutes", "30 Minutes")
	end

	newproperty(:thermalshutdown) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:custompostmessage) do
		newvalues("")
	end

	newproperty(:rbsulanguage) do
		newvalues("")
	end

	newproperty(:pxenic1) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pxenic2) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pxenic3) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pxenic4) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pxenic5) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:biosconsole) do
		newvalues("Disabled", "COM1", "COM2", "Auto", "COM3", "COM4")
	end

	newproperty(:biosbaudrate) do
		newvalues("9600", "19200", "57600", "115200")
	end

	newproperty(:biostype) do
		newvalues("VT100", "ANSI")
	end

	newproperty(:emsconsole) do
		newvalues("Disabled", "Local", "Remote", "COM1", "COM2", "COM3", "COM4")
	end

	newproperty(:biosinterfacemode) do
		newvalues("Full Screen Mode", "CLI Mode", "Auto Mode")
	end

	newproperty(:sanbootcontrollerorder) do
		newvalues("Default", "Fibre First")
	end

	newproperty(:sanbootembeddedcontroller) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:systemembeddedide) do
		newvalues("Secondary_Disabled", "Enabled", "Disabled")
	end

	newproperty(:embeddedvirtualdisk) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:virtualinstalldisk) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:hppowerregulator) do
		newvalues("OS_Control_Mode", "HP_Static_Low_Power_Mode", "HP_Dynamic_Power_Savings_Mode", "HP_Static_High_Performance_Mode")
	end

	newproperty(:hwprefetch) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:adjacentsectorprefetch) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:atadrivewritecache) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:embeddedsataconfiguration) do
		newvalues("SATA_Legacy_Enabled", "SATA_RAID_Enabled", "SATA_AHCI_Enabled")
	end

	newproperty(:hpdynamicsmartarrayraidcontroller) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:biosenhancedraid) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:noexecutememoryprotection) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:legacyserr) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:cpuvirtualization) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:embeddednic) do
		newvalues("")
	end

	newproperty(:linuxhpettimer) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:disketteboot) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:numlock) do
		newvalues("On", "Off")
	end

	newproperty(:postspeedup) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:integrateddiskettecontroller) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pcibusreset) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:hotplugreservation) do
		newvalues("Disabled", "Normal", "Extensive", "Auto Set")
	end

	newproperty(:memoryprotection) do
		newvalues("Advanced_ECC_Support", "Online_Spare_with_Advanced_ECC", "Mirrored_with_Advanced_ECC", "Lockstep_Mode_with_Advanced_ECC", "RAID", "Advanced_ECC_with_Hot-Add_support)")
	end

	newproperty(:advancedmemoryprotectiongen8) do
		newvalues("Advanced_ECC_Support", "Online_Spare_with_Advanced_ECC")
	end

	newproperty(:automaticpoweron) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:automaticpowerongen8) do
		newvalues("Always_Power_On", "Always_Remain_Off", "Restore_Last_Power_State")
	end

	newproperty(:powerondelay) do
		newvalues("No_Delay", "15_Second", "30_Second", "45_Second", "60_Second", "Random")
	end

	newproperty(:usbcapability) do
		newvalues("USB_2.0", "USB_1.1")
	end

	newproperty(:pcienumerationmethod) do
		newvalues("Standard", "Legacy")
	end

	newproperty(:rcmode) do
		newvalues("Admin_NOSEG", "User_NOSEG", "Setup_NOSEG", "Admin_SEG", "User_SEG", "Setup_SEG")
	end

	newproperty(:assettagprotection) do
		newvalues("Unlocked", "Locked")
	end

	newproperty(:sharediloport) do
		newvalues("Dedicated_Port", "Shared_Port")
	end

	newproperty(:optionromloadingsequence) do
		newvalues("Option_Card_First", "Embedded_First")
	end

	newproperty(:removableflashmediabootsequence) do
		newvalues("Internal_Drivekeys_First", "External_Drivekeys_First", "Internal_SD_Card_First")
	end

	newproperty(:usbportbootorderg5) do
		newvalues("Internal", "External")
	end

	newproperty(:usbportbootorderg6) do
		newvalues("Internal", "External", "SD_Card")
	end

	newproperty(:usbbootsupport) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:lowpowerhaltstate) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelprocessorcoredisable) do
		newvalues("All_Cores_Enabled", "One_Core_Enabled", "Half_Core_Enabled")
	end

	newproperty(:intelprocessorturbomode) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelvtd2) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:hppowerprofile) do
		newvalues("Balanced", "Minimum_Power", "Maximum_Performance", "Custom")
	end

	newproperty(:intelqpilinkpowermanagement) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelqpilinkfrequency) do
		newvalues("Auto", "Min_QPI_Speed")
	end

	newproperty(:intelminimumprocessoridlepowerstate) do
		newvalues("No_C-States", "C1E_State", "C3_State", "C6_State")
	end

	newproperty(:intelminimumprocessoridlepowerpackagestate) do
		newvalues("No_Package_State", "Package C3 State", "Package_C6_State")
	end

	newproperty(:maximummemorybusfrequency) do
		newvalues("Auto", "800MHz", "1066MHz", "1333MHz")
	end

	newproperty(:memoryinterleaving) do
		newvalues("Full_Interleaving", "Channel_Only_Interleaving", "No_Interleaving")
	end

	newproperty(:intelpciexpressgeneration20support) do
		newvalues("Auto", "Force_PCI-E_Generation_1", "Force_PCI-E_Generation_2")
	end

	newproperty(:thermalconfiguration) do
		newvalues("Optimal_Cooling", "Increased_Cooling", "Maximum_Cooling")
	end

	newproperty(:thermalconfigurationml350g6) do
		newvalues("Optimal_Cooling", "Increased_Cooling", "Reduced_Acoustics")
	end

	newproperty(:inteltpmfunctionality) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:inteltpmvisibility) do
		newvalues("Unhide", "Hide")
	end

	newproperty(:inteltpmexpansionrommeasuring) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:amdtpmfunctionality) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:amdtpmvisibility) do
		newvalues("Unhide", "Hide")
	end

	newproperty(:amdtpmexpansionrommeasuring) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:tpmfunctionalitygen8) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:tpmvisibilitygen8) do
		newvalues("Unhide", "Hide")
	end

	newproperty(:tpmexpansionrommeasuringgen8) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:nodeinterleaving) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelhyperthreading) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:amdrevfnodeinterleaving) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pcibuspaddingoption) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:pcibuspaddingoptiongen8) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:poweronlogo) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:hideoptionrommessages) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:redundantpowersupplymode) do
		newvalues("Balanced_Mode", "High_Efficiency_Auto", "High_Efficiency_Odd_Standby", "High_Efficiency_Even_Standby")
	end

	newproperty(:dynamicpowersavingsmoderesponse) do
		newvalues("Fast", "Slow", "Slow_Gen8")
	end

	newproperty(:memoryspeedwith2dimmsperchannel) do
		newvalues("1066MHz_Maximum", "1333MHz_Maximum")
	end

	newproperty(:videooptions) do
		newvalues("Optional_Primary_Embedded_Disabled", "Optional_Primary_Embedded_Secondary", "Embedded_Primary_Optional_Secondary")
	end

	newproperty(:nic1ports) do
		newvalues("All_Enabled", "Port2_Disabled", "All_Disabled")
	end

	newproperty(:nic2ports) do
		newvalues("All_Enabled", "Port2_Disabled", "All_Disabled")
	end

	newproperty(:embeddednic2) do
		newvalues("Enable", "Disable")
	end

	newproperty(:hypertransport) do
		newvalues("HT1", "HT3", "Invalid_Setting_1", "Invalid_Setting_2")
	end

	newproperty(:hypertransportg7) do
		newvalues("HT3", "HT1")
	end

	newproperty(:coherentlink) do
		newvalues("Dual_Coherent_Link", "Single_Coherent_Link")
	end

	newproperty(:powersupplyrequirementsoverride) do
		newvalues("Normal", "2_Required_3_Redundancy", "1_Required_2_Redundancy")
	end

	newproperty(:powersupplyrequirementsoverridedl580g7) do
		newvalues("Default", "1_Required_2_Redundancy", "2_Required_3_Redundancy", "2_Required_4_Redundancy", "3_Required_4_Redundancy", "4_Required_0_Redundancy")
	end

	newproperty(:remotegraphicsmode) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:amdultralowpowermode) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:hemispheremode) do
		newvalues("Auto", "Disabled")
	end

	newproperty(:pciexpresspowermanagementoptions) do
		newvalues("Optimized_Power_Performance", "Optimized_Power", "Disabled")
	end

	newproperty(:intelnicdmachannels) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:collaborativepowercontrol) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:amdpciexpressgeneration20support) do
		newvalues("Enabled", "Force_PCI-E_Generation_1", "Force_PCI-E_Generation_2")
	end

	newproperty(:amdminimumprocessoridlepowerstate) do
		newvalues("No_C-States", "C1E_State", "C6_State")
	end

	newproperty(:amdprocessorcoredisableg7) do
		newvalues("2_Cores_Enabled", "4_Cores_Enabled", "6_Cores_Enabled", "8_Cores_Enabled", "10_Cores_Enabled", "12_Cores_Enabled")
	end

	newproperty(:processorcoredisablegen8) do
		newvalues("All_Cores_Enabled", "1_Core_Enabled", "2_Cores_Enabled", "3_Cores_Enabled", "4_Cores_Enabled", "5_Cores_Enabled", "6_Cores_Enabled", "7_Cores_Enabled", "8_Cores_Enabled", "9_Cores_Enabled", "10_Cores_Enabled", "11_Cores_Enabled", "12_Cores_Enabled", "13_Cores_Enabled", "14_Cores_Enabled", "15_Cores_Enabled", "16_Cores_Enabled")
	end

	newproperty(:amdhpcoptimizationmode) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:amdcoreperformanceboost) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:amdmemoryinterleaving) do
		newvalues("No_Interleaving", "Channel_Interleaving")
	end

	newproperty(:amdmemoryinterleavinggen8) do
		newvalues("No_Interleaving", "Channel_Interleaving")
	end

	newproperty(:amdcoreselectg6) do
		newvalues("All_Cores_Enabled", "One_Core_Enabled", "Two_Cores_Enabled", "Three_Cores_Enabled", "Four_Cores_Enabled", "Five_Cores_Enabled")
	end

	newproperty(:amdmemorychannelmode) do
		newvalues("Combined_Mode", "Independent_Mode")
	end

	newproperty(:memorypowercapping) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:dimmidlepowersavingmode) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:memorymappediooptions) do
		newvalues("2GB_Memory_Mapped", "3GB_Memory_Mapped", "Automatic_Memory_Mapped")
	end

	newproperty(:addressmode44bit) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:dcuprefetcher) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:datareuse) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:nic1personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic2personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic3personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic4personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic5personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic6personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic7personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:nic8personality) do
		newvalues("Ethernet", "iSCSI", "FCoE")
	end

	newproperty(:qpibandwidthoptimization) do
		newvalues("Balanced", "Optimized_for_Memory", "Optimized_for_IO")
	end

	newproperty(:qpibandwidthoptimizationgen8) do
		newvalues("Balanced", "Optimized_for_IO")
	end

	newproperty(:intelturboboostoptimization) do
		newvalues("Optimized_for_Performance", "Optimized_for_Power")
	end

	newproperty(:hpproliantvoodootechnologyprocessorcoredisable) do
		newvalues("All_Cores_Enabled", "One_Core_Enabled", "Two_Cores_Enabled", "Four_Cores_Enabled")
	end

	newproperty(:hpproliantvoodootechnology) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:hpproliantvoodootechnologyprocessorspeed) do
		newvalues("")
	end

	newproperty(:hpproliantvoodootechnologyvoltage) do
		newvalues("")
	end

	newproperty(:embeddedserialportconnector) do
		newvalues("Automatically_Switch_to_SUV", "Front_Serial_Port")
	end

	newproperty(:pciedeemphasisonmezz) do
		newvalues("-6db", "-3.5db")
	end

	newproperty(:intelturboboostoptimizationgen8) do
		newvalues("Optimized_for_Low_Power", "Optimized_for_Power_Efficiency", "Optimized_for_Performance", "Disabled")
	end

	newproperty(:intelpciexpressgen3embeddedstoragedevicecontrol) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3embeddednic1devicecontrol) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3embeddednic2devicecontrol) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice1control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice2control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice3control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice4control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice5control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice6control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice7control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3systemspecificdevice8control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot1control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot2control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot3control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot4control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot5control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot6control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot7control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot8control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot9control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot10control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot11control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot12control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot13control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot14control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot15control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelpciexpressgen3slot16control) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:x2apicoptions) do
		newvalues("Auto", "Disabled")
	end

	newproperty(:intelf11bootmenuprompt) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:amdf11bootmenuprompt) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:intelligentprovisioningf10prompt) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:energyperformancebias) do
		newvalues("Balanced_Performance", "Maximum_Performance", "Balanced_Power", "Power_Savings_Mode")
	end

	newproperty(:i1333mhzsupportfor3dpcpc310600hhpsmartmemory) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:systemlocalityinformationtableg7) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:systemlocalityinformationtablegen8) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:inteldimmvoltagepreference) do
		newvalues("Optimized_for_Power", "Optimized_for_Performance")
	end

	newproperty(:amddimmvoltagepreference) do
		newvalues("Optimized_for_Power", "Optimized_for_Performance")
	end

	newproperty(:userdefineddefaults) do
		newvalues("Save", "Erase")
	end

	newproperty(:intelmemorychannelmodegen8) do
		newvalues("Independent_Channel_Mode", "Combined_Channel_Mode")
	end

	newproperty(:dynamicpowercappingfunctionality) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:sriov) do
		newvalues("Disabled", "Enabled")
	end

	newproperty(:memorypowersavingsmode) do
		newvalues("Balanced", "Maximum_Performance")
	end

	newproperty(:networkbootretrysupport) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:hpoptionromprompting) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:resetonbootdevicenotfound) do
		newvalues("Enabled", "Disabled")
	end

	newproperty(:smilinkpowermanagement) do
		newvalues("Enabled", "Disabled")
	end

end
# vim:sw=2:ts=2:et:
