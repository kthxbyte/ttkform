## \file validation.tcl
# Validation functions to be used by validate methods in all classes derived
# from tf::Widget.
#
namespace eval tf {
	set FALSE 0
	set TRUE 1

	## \brief Returns tf::FALSE if the form field is empty.
	#
	proc required {field} {
		if {[string trim [$field getValue]] eq {}} {
			return $tf::FALSE
		}
		return $tf::TRUE
	}
	
	##\brief Returns tf::FALSE if the form field does not match the specified content.
	#
	proc matches {field content} {
		if {[$field getValue] eq $content} {
			return $tf::TRUE
		}
		return $tf::FALSE
	}
	
	##\brief Returns tf::FALSE if the form field is shorter than the mininum specified.
	#
	proc min_length {field length} {
		if {[string length [$field getValue]] < $length} {
			return $tf::FALSE
		} 
		return $tf::TRUE
	}

	##\brief Returns tf::FALSE if the form field is longer than the mininum specified.
	#
	proc max_length {field length} {
		if {[string length [$field getValue]] > $length} {
			return $tf::FALSE
		} 
		return $tf::TRUE
	}
	
	##\brief Returns tf::FALSE if the form field is not exactly the length specified.
	#
	proc exact_length {field length} {
		if {[string length [$field getValue]] != $length} {
			return $tf::FALSE
		} 
		return $tf::TRUE
	}

	##\brief Returns tf::FALSE if the form field is equal or less than the number specified or not numeric.
	#
	proc greater_than {field number} {
		if {![string is digit [$field getValue]]} {
			return $tf::FALSE
		}
		if {[$field getValue] > $number} {
			return $tf::TRUE
		} 
		return $tf::FALSE
	}

	##\brief Returns tf::FALSE if the form field is equal or greater than the number specified or not numeric.
	#
	proc lesser_than {field number} {
		if {![string is digit [$field getValue]]} {
			return $tf::FALSE
		}
		if {[$field getValue] < $number} {
			return $tf::TRUE
		} 
		return $tf::FALSE
	}	
}
