# tf::Form class
package require Itcl
package require Ttk

namespace eval tf {	
	catch {itcl::delete class Form}

	## tf::Form deals with creation and management of forms. Forms are 
	# conceived as containers to hold lists of other tf::* objects, acting as 
	# fields in the form. 
	#
	itcl::class Form {
		inherit Widget
		protected variable fields {}
		protected variable rows {}
		protected variable columns {}
		protected variable title {}
		protected variable title_frame {}
		protected variable submit_command {}
		protected variable submit_message {}
		protected variable submit_button {}
		protected variable default_pack_settings "-fill x -anchor n -expand 1 -padx 6 -pady 6"
		
		## All objects derived from tf::Widget implement this method. This way,
		# you can turn on debugging for the individual object you're trying to
		# examine.
		#
		# \param message 
		# Message that will be printed. Debug messages usually look like \c 
		# "method_name: Debug message".
		#
		# \returns 
		# Nothing, it just prints a message on your console if debug
		# mode is on.
		#
		public method debugmsg {message} {
			if {$debug_mode eq "on"} {
				puts "$this\(tf::Form\)::$message"
			}
		}
		
		## Collects initialization arguments and calls \ref configure to 
		# process them. Nothing is displayed at this stage: to display this
		# object, you'll need a combination of \ref display and the \b pack command.
		#\param args 
		#	Configuration options in a \c "-property1 value1 -property2
		# 	value2 ..." list format. More details in \ref configure.
		#
		# Example:\code
		# tf::Entry myEntry -title "Age (years)"
		#\endcode
		#
		public method constructor {args} {
			# All defaults defined *before* processing arguments -- arguments override default values.
			set title $this
			set submit_message "Submit $this"
			configure {*}$args
		}
		
		## This method creates a ttk::labelframe and a submit button to display
		# the form. Further processing/packing of each element in the 
		# rows/columns list is performed internally by \ref displayFields.
		#\param container Tk-style path to an existing container: for example, 
		# an existing ttk::frame, or simply \c ".".
		#\param name Name for the path of the new ttk::frame.
		#\returns Full Tk-style path to the new ttk::labelframe, ready to be 
		# packed.
		#
		# Example:\code
		# toplevel .login
		# tf::Form loginForm -title " Connect to server " -submitmessage "Connect"
		# loginForm configure -columns [list  \ \
		 	[list \
				[tf::Entry myUsername -title "Username"] \
				[tf::Entry myPassword -title "Password" -show "*"] \
			] \
		 ] 
		# pack [loginForm display .login form] -fill x -expand 1 -anchor n
 		#\endcode		
		#
		public method display {container name} {
			if {$container eq "."} {set container ""}
			if {$title_frame ne {}} {
				debugmsg "display: title_frame already exists ($title_frame). Destroying."
				destroy $title_frame
			}
			if {[winfo exists $container.$name]} {
				debugmsg "display: no title_frame, but $container.$name already exists. Destroying."
				destroy $container.$name
			}
			# Create the container frame, put inside a submit button, then display all registered fields.
			set title_frame [ttk::labelframe $container.$name -text $title -padding 6]
			set button_frame [ttk::frame $title_frame.submit] 
			set submit_button [ttk::button $button_frame.button -text $submit_message -command $submit_command]
			pack $submit_button -side bottom -padx 6 -pady 4
			pack $button_frame -side bottom
			
			displayFields
			return $title_frame
		}
		
		## Process configuration options in a rather tcl'ish fashion.
		#\param args 
		#	Configuration options in a \c "-option1 value1 -option2 value2 ..."
		#	list format. Currently supported options are:
		#- \b -title 
		#	Sets a title for this object.
		#- \b -debug
		#	Set to "on" turns on debug messages for this object. To disable,
		#	set this option to "off". All objects are set to "off" by default.
		#- \b -rows 
		#	Arranges a number of fields in rows. The structure used to describe
		#	the fields is a list (representing rows) of lists 
		#	(containing the actual fields), such as: \code
		#	connectForm configure -rows [list \ \
				[list \
					[tf::Entry formUser -title "Username"] \
					[tf::Entry formPass -title "Password" -show "*"] \
				] \
				[list \
					[tf::Entry formServer -title "Server IP" -validcharacters "1234567890."] \
					[tf::Entry formPort -title "Server port" -validcharacters "1234567890"] \
				] \
			] \endcode
		#	In this example, the list containing formUser and formPass will be
		#	the first row, whereas formServer and formPort will be displayed in
		#	the second row. The backslashes are needed if you want this 
		#	command to span several lines and force a hierarchy tree look 
		#	on what actually is a single line of code.
		#- \b -columns
		#	Arranges a number of fields in columns. The structure used to 
		#	describe the fields is exactly the same you see above.
		#- \b -submitmessage
		#	Specifies a message for the "submit" button.
		#- \b -submitcommand
		#	Specifies a script to be executed when the user presses the
		#	"submit" button. The following example uses \ref getValues to dump
		#   the contents of all fields in the myForm object: 
		#	\code
		#	myForm configure -submitcommand {
		#		puts "Collected data:"
		#		array set data [myForm getValues]
		#		parray data
		#	} \endcode
		#.
		# If no arguments are provided, the object will return a list with 
		# its current settings. It is not currently possible to query a given
		# property by simply calling to \c "configure -property".
		#
		public method configure {args} {
			if {$args eq {}} {
				puts "-title ($title) -rows ($rows) -columns ($columns) -fields ($fields) -submitmessage ($submit_message) -submitcommand ($submit_command)"
			}
			array set options $args
			set unknown_options {}
			foreach option [array names options] {
				switch $option {
					"-title" {
						set title $options($option)
						if {$title_frame ne {}} {
							if {[winfo exists $title_frame]} {
								$title_frame configure -text $title
							}
						}
					}
					"-rows" {
						if {$columns ne {}} {
							debugmsg "configure: this object is arranged in columns already ($columns). Removing columns."
							set columns {}
						}
						set rows $options($option)
						if {$title_frame ne {}} {
							destroy $title_frame
							set widget_path [split $title_frame "."]
							set container ".[join [lrange $widget_path 1 end-1] "."]"
							set name [lrange $widget_path end end]
							eval pack [display $container $name] $default_pack_settings
						}
					}
					"-columns" {
						if {$rows ne {}} {
							debugmsg "configure: this object is arranged in rows already ($rows). Removing rows."
							set rows {}
						}
						set columns $options($option)
						if {$title_frame ne {}} {
							destroy $title_frame
							set widget_path [split $title_frame "."]
							set container ".[join [lrange $widget_path 1 end-1] "."]"
							set name [lrange $widget_path end end]
							eval pack [display $container $name] $default_pack_settings
						}
					}
					"-submitmessage" {
						if {$submit_message ne $this} {
							debugmsg "configure: Submit message already defined ($submit_message). Overwriting."
						}
						set submit_message $options($option)
						if {$submit_button ne {}} {
							if {[winfo exists $submit_button]} {
								$submit_button configure -text $submit_message
							}
						}
					}
					"-submitcommand" {
						if {$submit_command ne {}} {
							debugmsg "configure: Submit command already defined ($submit_command). Overwriting."
						}
						set submit_command $options($option)
						if {$submit_button ne {}} {
							if {[winfo exists $submit_button]} {
								$submit_button configure -command $submit_command
							}
						}
					}
					default {
						debugmsg "configure: Unknown option '$option', will be reprocessed by parent method"
						lappend unknown_options $option $options($option)
					}
				}
			}
			# All unknown options are collected and re-processed by the parent method. Good luck there.
			if {$unknown_options ne {}} {
				chain {*}$unknown_options
			}
		}
		
		## Method used internally during the display process. It determines
		# if the fields are arranged in rows or columns, calling 
		# \ref displayRows or \ref displayColumns accordingly. Chances are
		# you'll never call this method directly.
		#
		public method displayFields {} {
			if {$rows ne {}} {
				displayRows
				return
			}
			if {$columns ne {}} {
				displayColumns
				return
			}
			debugmsg "displayFields: no fields to display."
		}

		## Method used internally during the display process. It creates a 
		# ttk::frame for each row, then packs the corresponding fields inside.
		# Chances are you'll never call this method directly.
		#
		public method displayRows {} {
			set row_counter 0
			foreach row $rows {
				# Set up a container frame for each row
				incr row_counter
				set frame_row [ttk::frame $title_frame.row$row_counter]
				set field_counter 0
				
				# Then pack all fields in that row.
				foreach field $row {
					if {[itcl::is object -class tf::Widget $field]} {
						incr field_counter
						pack [$field display $frame_row field$field_counter] -side left -fill x -expand 1
						$field configure -form $this
					} else {
						debugmsg "displayRows: field $field is not a tf::Widget, skipping"
					}
				}
				pack $frame_row -side top -fill x
			}
		}

		## Method used internally during the display process. It creates a 
		# ttk::frame for each column, then packs the corresponding fields 
		# inside. Chances are you'll never call this method directly.
		#		
		public method displayColumns {} {
			set column_counter 0
			foreach column $columns {
				# Set up a container frame for each column
				incr column_counter
				set frame_column [ttk::frame $title_frame.column$column_counter]
				set field_counter 0
				
				# Then pack all fields in that column.
				foreach field $column {
					if {[itcl::is object -class tf::Widget $field]} {
						incr field_counter
						pack [$field display $frame_column field$field_counter] -side top -fill x -expand 1
						$field configure -form $this
					} else {
						debugmsg "displayColumns: field $field is not a tf::Widget, skipping"
					}
				}
				pack $frame_column -side left -anchor n -fill x -expand 1 
			}
		}

		## Destroys the associated ttk::labelframe widget, if any.
		#
		public method destructor {} {
			if {$title_frame ne {}} {
				if {[winfo exists $title_frame]} {
					destroy $title_frame
				}
			}
		}
		
		## Iterate over all fields, calling their own verifier methods, 
		# catching errors and marking the fields that failed the test.
		# The error message produced by the first field that fails is displayed
		# in the "submit" button, which automatically gets disabled.
		#
		public method verify {} {
			if {$rows ne {}} {
				set field_containers $rows
			}
			if {$columns ne {}} {
				set field_containers $columns
			}
			if {![info exists field_containers]} {
				debugmsg "verify: no fields to verify."
				return
			}
			# TODO: Implement this NOW. In the same fashion, all tf::* objects
			#		should implement a verify method as well.
		}
		
		## Iterate over all fields, capturing their contents and producing a 
		# list as a result.
		# \returns
		# A list of \c "title value" pairs. The resulting list can be used
		# directly to create an array, making the results more easily accessible.
		#
		#	The following example uses \ref getValues to dump
		#   the contents of all fields in the myForm object: 
		#	\code
		#	myForm configure -submitcommand {
		#		puts "Collected data:"
		#		array set data [myForm getValues]
		#		parray data
		#	} \endcode
		#
		public method getValues {} {
			if {$rows ne {}} {
				set field_containers $rows
			}
			if {$columns ne {}} {
				set field_containers $columns
			}
			if {![info exists field_containers]} {
				debugmsg "getValues: no fields, no data."
				return
			}
			set data_pairs {}
			foreach field_list $field_containers {
				foreach field $field_list {
					if {[itcl::is object -class tf::Widget $field]} {
						# Go recursive on nested tf::Form objects and capture its fields as well.
						if {[itcl::is object -class tf::Form $field]} {
							foreach {name value} [$field getValues] {
								lappend data_pairs $name $value
							}
						} else {
							set name [$field getTitle]
							set value [$field getValue]
							lappend data_pairs $name $value
						}
					} else {
						debugmsg "getValues: field $field is not a tf::Widget, skipping"
					}
				}
			}
			return $data_pairs
		}
	}
}


