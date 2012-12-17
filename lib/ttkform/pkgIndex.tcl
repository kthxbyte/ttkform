# Providing ttkform.

package require Itcl
package require Ttk

# Configure a few font styles for ttk::button and ttk::label
namespace eval tf {
	set font_style [font actual [ttk::style lookup TLabel -font]]
	ttk::style configure Normal.TLabel -font $font_style
	dict set font_style -weight bold
	ttk::style configure Bold.TLabel -font $font_style
	
	set font_style [font actual [ttk::style lookup TButton -font]]
	ttk::style configure Normal.TButton -font $font_style
	dict set font_style -weight bold
	ttk::style configure Bold.TButton -font $font_style
	
	unset font_style
}

source [file join $dir widget.tcl]
source [file join $dir entry.tcl]
source [file join $dir form.tcl]
source [file join $dir validation.tcl]

package provide ttkform 2012.12.17
