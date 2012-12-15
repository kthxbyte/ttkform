# tf::Entry class
package require Itcl
package require Ttk

namespace eval tf {
	catch {itcl::delete class Entry}
	
	## A tf::Entry object provides a thin abstraction layer for ttk::entry. It
	# allows you to establish properties such as a limited character set or 
	# rules to be met by user input.
	#
	itcl::class Entry {
		inherit Widget
		protected variable valid_characters {}
		protected variable show_character {}

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
				puts "$this\(tf::Entry\)::$message"
			}
		}
		
		## Collects initialization arguments and calls \ref configure to 
		# process them. Nothing is displayed at this stage: to display this
		# object, you'll need a combination of \ref display and the \b pack command.
		#\param args 
		#	Configuration options in a \c "-option1 value1 -option2 value2 ..."
		#	list format. More details in \ref configure.
		#
		# Example:\code
		# tf::Entry myEntry -title "What is your name?"
		#\endcode
		#
		public method constructor {args} {
			configure {*}$args
		}

		## Process configuration options in a rather tcl'ish fashion.
		#\param args 
		#	Configuration options in a \c "-option1 value1 -option2 value2 ..."
		#	list format. Currently supported options are:
		#
		#- \b -title 
		#	Sets a title for this object.
		#- \b -form 
		#	Links this entry to a tf::Form object. Changes in user input
		# will force a re-verification of the linked tf::Form object.
		#- \b -value 
		#	Sets a new value for this object. Implemented for convenience, it 
		#	does pretty much the same as calling \ref setValue.
		#- \b -validcharacters 
		#	Limits user input to a specific character set.
		#- \b -show 
		#	Replaces actual characters in the ttk::entry widget with
		# an arbitrary character. Try \c "-show *" for a password field. 
		#- \b -debug
		#	Set to "on" turns on debug messages for this object. To disable,
		#	set this option to "off". All objects are set to "off" by default.
		#.
		# If no arguments are provided, the object will return a list with 
		# its current settings. It is not currently possible to query a given
		# property by simply calling to \c "configure -property".
		#
		# Example:\code
		# toplevel .form
		# tf::Entry myEntry
		# myEntry configure -title "Password" -show "*"
		# pack [myEntry display .form pass] -fill x -anchor n -expand 1
		#\endcode
		#
		public method configure {args} {
			if {$args eq {}} {
				puts "-title \{$title\}"
				puts "-form \{$parent_form\}"
				puts "-show \{$show_character\}"
				puts "-validcharacters \{$valid_characters\}"
			}
			array set options $args
			set unknown_options {}
			foreach option [array names options] {
				switch $option {
					"-validcharacters" {
						set valid_characters $options($option)
					}
					"-show" {
						set show_character $options($option)
						if {$widget ne {}} {
							if {[winfo exists $widget]} {
								$widget configure -show $show_character
							}
						}
					}
					default {
						#puts "$this (tf::Entry): Ignoring unknown option '$option'"
						lappend unknown_options $option $options($option)
					}
				}
			}
			# All unknown options are collected and re-processed by the parent method. Good luck there.
			if {$unknown_options ne {}} {
				chain {*}$unknown_options
			}
		}
		
		## Creates the required GUI elements to display the title 
		# and an entry box. All this gets packed inside a new ttk::frame.
		#
		#\param container 
		#	Path name to an existing container: for example, an existing 
		#	ttk::frame, or simply \c ".".
		#\param name 
		#	Tk name for the new container ttk::frame.
		#\returns 
		#	Path name for the new ttk::frame, ready to be packed.
		#
		# Example:\code
		# toplevel .form
		# tf::Entry myEntry
		# myEntry configure -title "Age (years)" -validcharacters "1234567890"
		# pack [myEntry display .form age] -fill x -expand 1 -anchor n
 		#\endcode
		#
		public method display {container name} {
			chain $container $name			
			set widget [ttk::entry $box.entry -textvariable [itcl::scope stored_value]]
			$widget configure \
				-validate key \
				-show $show_character \
				-validatecommand "$this filterInput %S %d"
			pack $widget -side top -fill x -expand 1
			return $box
		}
		
		## Internal validation method, there should be no need at all to call
		# this method directly. It is publicly exposed only for implementation 
		# reasons: this method is used as a \c -validatecommand for the internal 
		# ttk::entry widget, allowing to limit the valid character set. That is 
		# related to the \c -validcharacters option in \ref configure.
		#\param input The character that is being tested in the ttk::entry 
		# widget. 
		#\param insert_or_delete A boolean switch to specify if a character is
		# being inserted or deleted in the ttk::entry widget.
		#
		public method filterInput {input insert_or_delete} {
			# No filter? There's nothing to do here then.
			if {$valid_characters eq {}} {
				return 1
			}
			# Don't worry about deletion/backspace. It's ok.
			if {$insert_or_delete eq 0} {
				return 1
			}
			# Accept only characters present in the valid_characters list.
			if {[lsearch [split $valid_characters ""] $input] == -1} {
				return 0
			}
			# So, it was valid input after all.
			return 1
		}		
	}
}