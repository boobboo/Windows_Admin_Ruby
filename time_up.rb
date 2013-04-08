require 'rubygems'
require 'ruby-wmi'
require 'date'

str = WMI::Win32_OperatingSystem.find(:first).LastBootupTime

	time = Time.new
	boot = DateTime.strptime(str, "%Y%m%d%H%M")
	boot_date = boot.strftime("%Y %b")
	boot_time = boot.strftime("%I:%M")
#puts "Last reboot: #{boot_date} at #{boot_time}"
#puts boot_time
	time_gap = time.hour - DateTime.parse(boot_time).hour
#puts time_gap

	if time_gap > 4
		print "Time to shut down"
		exec ("notepad.exe")
	else
		print " keep going"
		exec ("dir c:\ >c:\temp\dirt.txt")
	end
