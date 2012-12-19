# You're not going to need this if you copy the ttkform directory inside one 
# of the directories specified in auto_path.
lappend auto_path [file join [pwd] lib]

package require ttkform

proc testform {} {
	toplevel .form
	wm title .form "Test Form"
	
	tf::Form dataForm -title " Try filling these fields " -submitmessage "Done"
	dataForm configure -columns [list \
		[list \
			[tf::Entry username -title "Username"] \
			[tf::Entry password -title "Password"] \
			[tf::Entry phone  -title "Phone number"] \
		] \
	]
	dataForm configure -submitcommand {
		array set data [dataForm getValues]
		parray data
	}
	
	# Form field restrictions
	username configure -rules {{required "Username required"}} \
		-validcharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzñÑ"

	password configure -show "*" \
		-rules {{required "Password required"} \
				{min_length 8 "Password too short"}}
		
	phone configure -validcharacters "1234567890-+" \
		-rules {{required "Phone number required"}}
	
	# Ready to display
	pack [dataForm display .form data] -fill x -expand 1 -anchor n -padx 10 -pady 10
}

testform
