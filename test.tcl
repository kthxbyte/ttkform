# You're not going to need this if you copy the ttkform directory inside one 
# of the directories specified in auto_path.
lappend auto_path [file join [pwd] lib]

package require ttkform

proc test1 {} {
	toplevel .login
	tf::Form connectForm -title " Connect to server " -submitmessage "Connect"
	connectForm configure -rows [list \
		[list \
			[tf::Entry formUser -title "Username" -value "user"] \
			[tf::Entry formPass -title "Password" -show "*" -value "pass"] \
		] \
		[list \
			[tf::Entry formServer -title "Server IP" -validcharacters "1234567890." -value "127.0.0.1"] \
			[tf::Entry formPort -title "Server port" -validcharacters "1234567890" -value 21] \
		] \
	]
	connectForm configure -submitcommand { 
		array set data [connectForm getValues] 
		puts "\nCollected data:" 
		parray data 
	} 
	pack [connectForm display .login form] -fill x -expand 1 -anchor n
}

test1
