# tf::Widget class
package require Itcl
package require Ttk

namespace eval tf {
    catch {itcl::delete class Widget}

	## tf::Widget is the base class for all other tf::* classes you'll find.
	# It implements basic features common to all other classes and its use
	# is internal: chances are you'll never use it directly in your scripts.
	#
	itcl::class Widget {
		protected variable stored_value {}
		protected variable title {}
		protected variable title_label {}
		protected variable widget {}
		protected variable box {}
		protected variable parent_form {}
		protected variable debug_mode "off"
		
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
				puts "$this\(tf::Widget\)::$message"
			}
		}

		## This base class constructor simply sets the object name as title. 
		# That is usually overridden later by the constructor in the child 
		# class, during option processing.
		#
		public method constructor {} {
			set title $this
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
		#	will force a re-verification of the linked tf::Form object.
		#- \b -value 
		#	Sets a new value for this object. Implemented for convenience, it 
		#	does pretty much the same as calling \ref setValue.
		#- \b -show 
		#	Replaces actual characters in the ttk::entry widget with
		#	an arbitrary character. Try \c "-show *" for a password field. 
		#- \b -debug
		#	Set to "on" turns on debug messages for this object. To disable,
		#	set this option to "off". All objects are set to "off" by default.
		#.
		# If no arguments are provided, the object will return a list with 
		# its current settings. It is not currently possible to query a given
		# property by simply calling to \c "configure -property".
		#
		public method configure {args} {
			array set options $args
			foreach option [array names options] {
				switch $option {
					"-debug" {
						set debug_mode $options($option)
						if {$options($option) eq "on"} {
							debugmsg "configure: debug mode on"
						} else {
							set debug_mode "on"
							debugmsg "configure: debug mode off"
							set debug_mode "off"
						}
					}
					"-title" {
						set title $options($option)
						if {$title_label ne {}} {
							if {[winfo exists $title_label]} {
								$title_label configure -text $title
							}
						}
					}
					"-form" {
						if {$parent_form ne {}} {
							debugmsg "configure: This field is already attached to form $parent_form. Will detach and reattach to $options($option)."
						} else {
							debugmsg "configure: attached to form $options($option)"
						}
						set parent_form $options($option)
					}
					"-value" {
						if {$stored_value ne {}} {
							debugmsg "configure: This field already contains the value '$stored_value'. Overwriting with '$options($option)'."
						}
						set stored_value $options($option)
					}
					default {
						debugmsg "configure: Ignoring unknown option '$option'"
					}
				}
			}
		}
		
		## Overwrites the current value for this object.
		#\param content
		#	New value for this object. Be warned: this will bypass any input
		#	filter implemented by child classes such as tf::Entry.
		#
		public method setValue {content} {
			set stored_value $content
		}
		
		## Basic getter method, gets the current value stored in this object.
		#\returns 
		#	The current value stored in this object.
		#
		public method getValue {} {
			return $stored_value
		}
		
		## Basic getter method, gets the current title in this object.
		#\returns 
		#	The current title in this object.
		#
		public method getTitle {} {
			return $title
		}
		
		## Basic getter method, gets the current widget for this object. 
		# This may be useful if you need to perform further manipulation of the
		# ttk::* widget used by this object.
		#\returns Path name for the current widget, if there is any. Otherwise,
		#	it simply returns \c {}.
		#
		public method getWidget {} {
			return $widget
		}
		
		## Creates a ttk::frame as a container, then packs a ttk::label inside
		# to display the current title. If the ttk::frame already exists, it
		# is destroyed and re-created.
		#\param container 
		#	Tk-style path to an existing container: for example, an existing 
		#	ttk::frame, or simply \c ".".
		#\param name 
		#	Name for the path of the new ttk::frame.
		#\returns 
		#	Path name to the new ttk::labelframe, ready to be packed.
		# 
		public method display {container name} {
			if {$box ne {}} {
				debugmsg "display: box already exists ($box). Will destroy and re-create."
				destroy $box
			}
			if {$container eq "."} {set container ""}
			if {[winfo exists $container.$name]} {
				debugmsg "display: ttk::frame $container.$name already exists. Will destroy and re-create."
				destroy $container.$name
			}
			set box [ttk::frame $container.$name -padding 6]
			set title_label [ttk::label $box.title -text $title]
			pack $title_label -side top -fill x -expand 1
			
			# This should be packed properly outside.
			return $box
		}

		## Destroys the ttk::frame container, if any.
		#
		public method destructor {} {
			if {$box ne {}} {
				if {[winfo exists $box]} {
					destroy $box
				}
			}
		}
	}
}