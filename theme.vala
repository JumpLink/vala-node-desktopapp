/* Copyright (C) 2012  JumpLink (Pascal Garber)
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the Creative Commons licenses CC BY-SA 3.0.
 * License as published by the Creative Commons organisation; either
 * version 3.0 of the License, or (at your option) any later version.
 * More informations on: http://creativecommons.org/licenses/by-sa/3.0/ 
 *
 * Author:
 *	JumpLink (Pascal Garber) <pascal.garber@gmail.com>
 */

using Gtk;
using Gee;

public class Theme {

	Map<string, string> bootstrap_variable_map = new HashMap<string, string> ();
	Map<string, Gdk.RGBA?> current_gtk_colors_map = new HashMap<string, Gdk.RGBA?>();
	string current_font = ""; 
	int current_font_size = 0;
	Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
	string[] icon_theme_search_path;
	string icon_theme_name;
	string key_theme_name;
	Gtk.StyleContext style_context;
	Gtk.Settings settings;
	string icon_dir = "./public/images/icons";

	public Theme (Window window) {
		set_default_values();
		parseGtk3Theme(window);
		set_custom_values();
		write_less_file();
	}

	public void saveImages() {
		saveStockIcons(icon_dir+"/Stock");
		saveThemeIcons(icon_dir+"/Actions", "Actions");
		saveThemeIcons(icon_dir+"/Applications", "Applications");
		saveThemeIcons(icon_dir+"/Categories", "Categories");
		saveThemeIcons(icon_dir+"/MimeTypes", "MimeTypes");
		saveThemeIcons(icon_dir+"/Places", "Places");
		saveThemeIcons(icon_dir+"/Status", "Status");
	}

	private void printColorMap(HashMap<string, Gdk.RGBA?> colors) {
  		foreach (var entry in colors.entries) {
  			print("%s: %s\n", entry.key, entry.value.to_string ());
  		}
	}
	private void printiIconThemeSearchPath() {
		foreach (var path in icon_theme_search_path) {
			print("%s\n", path);
		}
	}
	// parsed the name and the value of config_strings in gtk.rc
	private HashMap<string, Gdk.RGBA?> parseRcColor(string s) {
		HashMap<string, Gdk.RGBA?> colors = new HashMap<string, Gdk.RGBA?>();

		int tmp_current_index = 0;
		int current_index = -1;
		int last_index = s.last_index_of_char(':', 0);
		string key;
		string val;
		while (last_index > 0 && tmp_current_index < last_index) {
			Gdk.RGBA color = new Gdk.RGBA();
			tmp_current_index = current_index;
			current_index = s.index_of_char(':', tmp_current_index+1);
			key = s.slice(tmp_current_index+1,current_index);
			key.chomp();
			if (key == "\"base_color") {	//WORKAROUND
				key = "base_color";
			}
			tmp_current_index = current_index;
			current_index = s.index_of_char('\n', tmp_current_index+1);
			val = s.slice(tmp_current_index+2,current_index);
			val.chomp();
			color.parse(val);
			colors[key] = color;
		}
		return colors;
	}

	public void set_custom_values () {
		Gdk.RGBA inputFocusBorder = new Gdk.RGBA();
		inputFocusBorder.parse(current_gtk_colors_map["selected_bg_color"].to_string());
		Gdk.RGBA inputFocusGlow = new Gdk.RGBA();
		inputFocusGlow.parse(current_gtk_colors_map["selected_bg_color"].to_string());
		inputFocusBorder.alpha = 0.8;
		inputFocusGlow.alpha = 0.6;
		bootstrap_variable_map["inputFocusBorder"] = 		inputFocusBorder.to_string();
		bootstrap_variable_map["inputFocusGlow"] = 			"inset 0 1px 1px rgba(0,0,0,.075), 0 0 8px " + inputFocusGlow.to_string();
		bootstrap_variable_map["systemFontFamily"] = 		"\""+current_font+"\"";
		bootstrap_variable_map["iconWhiteSpritePath"] = 	"\"../images/glyphicons-halflings-white.png\"";
		bootstrap_variable_map["iconSpritePath"] = 			"\"../images/glyphicons-halflings.png\"";
		bootstrap_variable_map["navbarHeight"] = 			"68px"; 
	}

	public void split_font_string(string font_string, out string name, out int size) {
		int last_whitespace = font_string.last_index_of_char(' ');
		name = font_string.slice(0,last_whitespace);
		size = int.parse(font_string.slice(last_whitespace+1, font_string.length ));
	}

	public void saveStockIcons(string dir) {
		var list_ids = Gtk.Stock.list_ids();
		//lookup_icon_set (string stock_id)
		//for (var i = 0; i < Gtk.Stock.list_ids().length)
		foreach (string id in list_ids) {
			//id = id.up().delimit("-",'_').replace("GTK_","STOCK_");
			//print("%s\n", id.to_string());
			//Gtk.Image stock_icon = new Gtk.Image.from_stock(id, Gtk.IconSize.MENU);
			//Gtk.Image stock_icon = new Gtk.Image.from_icon_name(id, Gtk.IconSize.MENU);
			GLib.Process.spawn_command_line_async("mkdir -p "+dir);
			GLib.Process.spawn_command_line_async("rm -f "+dir+"/*");
			try {
				var icon = style_context.lookup_icon_set(id);
				if (icon != null)
					icon.render_icon_pixbuf(style_context, Gtk.IconSize.LARGE_TOOLBAR).save(dir + "/" + id.to_string()+".png","png");
			}
			catch (Error e) {
				print(e.message);
			}
			//var pixbuf = stock_icon.get_pixbuf();
			//print(@"pixel_size: $(stock_icon.get_pixel_size())");
			//stock_icon.pixbuf.save(image_dir + id.to_string()+".png","png");
			saveThemeIcons(dir, "stock");
		}
	}

	public void saveThemeIcons(string dir, string context) {
		var icon_list = icon_theme.list_icons(context);
		foreach (string icon_name in icon_list) {
			//print("%s\n", icon_name);
			GLib.Process.spawn_command_line_async("mkdir -p "+dir);
			GLib.Process.spawn_command_line_async("rm -f "+dir+"/*");
			try {
				var icon = icon_theme.load_icon(icon_name, 24, Gtk.IconLookupFlags.USE_BUILTIN);
				if (icon != null)
					icon.save(dir + "/" + icon_name +".png","png");
			}
			catch (Error e) {
				print(e.message);
			}
		}
	}

	public void getGtkIcons(Gtk.Settings settings, Gtk.StyleContext style_context) {
        /* Gtk.IconTheme: http://valadoc.org/#!api=gtk+-3.0/Gtk.IconTheme */
        icon_theme.get_search_path(out icon_theme_search_path);
        icon_theme_name = settings.gtk_icon_theme_name;
        key_theme_name = settings.gtk_key_theme_name; //settings.gtk_theme_name
		
	}

	public void parseGtk3Theme(Window window) {
        style_context = window.get_style_context();
        settings = window.get_settings();
        Map<string, Gdk.RGBA?> colors = new HashMap<string, Gdk.RGBA?>();
        current_gtk_colors_map = parseRcColor(settings.gtk_color_scheme);
        split_font_string(settings.gtk_font_name, out current_font, out current_font_size);
        getGtkIcons(settings, style_context);
        
        bootstrap_variable_map["baseFontSize"] = 		current_font_size.to_string();
        bootstrap_variable_map["baseFontFamily"] = 		"@systemFontFamily";

       
        bootstrap_variable_map["bodyBackground"] = 		current_gtk_colors_map["bg_color"].to_string();
        bootstrap_variable_map["navbarBackgroundHighlight"] = 	current_gtk_colors_map["bg_color_dark"].to_string();
        bootstrap_variable_map["navbarBackground"] = 	"lighten(" + current_gtk_colors_map["bg_color_dark"].to_string() + ", 10%)";

        bootstrap_variable_map["textColor"] = 			current_gtk_colors_map["text_color"].to_string();
        bootstrap_variable_map["linkColor"] = 			current_gtk_colors_map["link_color"].to_string();

        // printColorMap(current_gtk_colors_map);
        // print("\n");
        print(Gtk.rc_get_theme_dir());
        print("\n");
        printiIconThemeSearchPath();
        print(icon_theme_name);
        print("\n");
        // print(settings.gtk_theme_name);
        // print("\n");
        // print(settings.gtk_key_theme_name);
        // print("\n");
         print(settings.gtk_color_palette);
         print("\n");
         print(settings.gtk_color_scheme);
         print("\n");
	}

	public void print_less_file() {
  		foreach (var entry in bootstrap_variable_map.entries) {
  			print("@%s: %s;\n", entry.key, entry.value);
  		}
	}

	public bool write_less_file () {
	    try {
	        // an output file in the current working directory
	        var file = File.new_for_path ("./public/stylesheets/variables.less");

	        // delete if file already exists
	        if (file.query_exists ()) {
	            file.delete ();
	        }

	        // creating a file and a DataOutputStream to the file
	        /*
	            Use BufferedOutputStream to increase write speed:
	            var dos = new DataOutputStream (new BufferedOutputStream.sized (file.create (FileCreateFlags.REPLACE_DESTINATION), 65536));
	        */
	        var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

	        // writing a short string to the stream
	        dos.put_string ("//File generated by...\n");

	  		foreach (var entry in bootstrap_variable_map.entries) {

	  			dos.put_string(@"@$(entry.key): $(entry.value);\n");
	  			//print("@%s: %s;\n", entry.key, entry.value);
	  		}

	        // // For long string writes, a loop should be used, because sometimes not all data can be written in one run
	        // // 'written' is used to check how much of the string has already been written
	        // uint8[] data = text.data;
	        // long written = 0;
	        // while (written < data.length) { 
	        //     // sum of the bytes of 'text' that already have been written to the stream
	        //     written += dos.write (data[written:data.length]);
	        // }
	    } catch (Error e) {
	        stderr.printf ("%s\n", e.message);
	        return true;
	    }

	    return false;
	}

	private void set_default_values() {

		// Variables.less
		// Variables to customize the look and feel of Bootstrap
		// -----------------------------------------------------



		// GLOBAL VALUES
		// --------------------------------------------------


		// Grays
		// -------------------------
		bootstrap_variable_map["black"] = 		"#000";
		bootstrap_variable_map["grayDarker"] = 	"#222"; 
		bootstrap_variable_map["grayDark"] = 	"#333"; 
		bootstrap_variable_map["gray"] = 		"#555"; 
		bootstrap_variable_map["grayLight"] = 	"#999"; 
		bootstrap_variable_map["grayLighter"] = "#eee"; 
		bootstrap_variable_map["white"] = 		"#fff"; 
		// @black:                 #000;
		// @grayDarker:            #222;
		// @grayDark:              #333;
		// @gray:                  #555;
		// @grayLight:             #999;
		// @grayLighter:           #eee;
		// @white:                 #fff;


		// Accent colors
		// -------------------------
		bootstrap_variable_map["blue"] = 		"#049cdb"; 
		bootstrap_variable_map["blueDark"] = 	"#0064cd"; 
		bootstrap_variable_map["green"] = 		"#46a546"; 
		bootstrap_variable_map["red"] = 		"#9d261d"; 
		bootstrap_variable_map["yellow"] = 		"#ffc40d"; 
		bootstrap_variable_map["orange"] = 		"#f89406"; 
		bootstrap_variable_map["pink"] = 		"#c3325f"; 
		bootstrap_variable_map["purple"] = 		"#7a43b6"; 
		// @blue:                  #049cdb;
		// @blueDark:              #0064cd;
		// @green:                 #46a546;
		// @red:                   #9d261d;
		// @yellow:                #ffc40d;
		// @orange:                #f89406;
		// @pink:                  #c3325f;
		// @purple:                #7a43b6;


		// Scaffolding
		// -------------------------
		bootstrap_variable_map["bodyBackground"] = 	"@white"; 
		bootstrap_variable_map["textColor"] = 		"@grayDark"; 
		// @bodyBackground:        @white;
		// @textColor:             @grayDark;


		// Links
		// -------------------------
		bootstrap_variable_map["linkColor"] = 		"#08c"; 
		bootstrap_variable_map["linkColorHover"] = 	"darken(@linkColor, 15%)";
		// @linkColor:             #08c;
		// @linkColorHover:        darken(@linkColor, 15%);


		// Typography
		// -------------------------
		bootstrap_variable_map["sansFontFamily"] = 		"\"Helvetica Neue\", Helvetica, Arial, sans-serif"; 
		bootstrap_variable_map["serifFontFamily"] = 	"Georgia, \"Times New Roman\", Times, serif"; 
		bootstrap_variable_map["monoFontFamily"] = 		"Menlo, Monaco, Consolas, \"Courier New\", monospace"; 
		// @sansFontFamily:        "Helvetica Neue", Helvetica, Arial, sans-serif;
		// @serifFontFamily:       Georgia, "Times New Roman", Times, serif;
		// @monoFontFamily:        Menlo, Monaco, Consolas, "Courier New", monospace;

		bootstrap_variable_map["baseFontSize"] = 	"13px"; 
		bootstrap_variable_map["baseFontFamily"] = 	"@sansFontFamily"; 
		bootstrap_variable_map["baseLineHeight"] = 	"18px"; 
		bootstrap_variable_map["altFontFamily"] = 	"@serifFontFamily"; 
		// @baseFontSize:          13px;
		// @baseFontFamily:        @sansFontFamily;
		// @baseLineHeight:        18px;
		// @altFontFamily:         @serifFontFamily;

		bootstrap_variable_map["headingsFontFamily"] = 	"inherit"; // empty to use BS default, @baseFontFamily
		bootstrap_variable_map["headingsFontWeight"] = 	"bold"; // instead of browser default, bold
		bootstrap_variable_map["headingsColor"] = 		"inherit"; // empty to use BS default, @textColor
		// @headingsFontFamily:    inherit; // empty to use BS default, @baseFontFamily
		// @headingsFontWeight:    bold;    // instead of browser default, bold
		// @headingsColor:         inherit; // empty to use BS default, @textColor


		// Tables
		// -------------------------
		bootstrap_variable_map["tableBackground"] = 		"transparent"; 	// overall background-color
		bootstrap_variable_map["tableBackgroundAccent"] = 	"#f9f9f9"; 		// for striping
		bootstrap_variable_map["tableBackgroundHover"] = 	"#f5f5f5"; 		// for hover
		bootstrap_variable_map["tableBorder"] = 			"#ddd"; 		// table and cell border
		// @tableBackground:                   transparent; // overall background-color
		// @tableBackgroundAccent:             #f9f9f9; // for striping
		// @tableBackgroundHover:              #f5f5f5; // for hover
		// @tableBorder:                       #ddd; // table and cell border


		// Buttons
		// -------------------------
		bootstrap_variable_map["btnBackground"] = "@white"; 
		bootstrap_variable_map["btnBackgroundHighlight"] = "darken(@white, 10%)"; 
		bootstrap_variable_map["btnBorder"] = "#ccc"; 
		// @btnBackground:                     @white;
		// @btnBackgroundHighlight:            darken(@white, 10%);
		// @btnBorder:                         #ccc;

		bootstrap_variable_map["btnPrimaryBackground"] = "@linkColor"; 
		bootstrap_variable_map["btnPrimaryBackgroundHighlight"] = "spin(@btnPrimaryBackground, 15%)"; 
		// @btnPrimaryBackground:              @linkColor;
		// @btnPrimaryBackgroundHighlight:     spin(@btnPrimaryBackground, 15%);

		bootstrap_variable_map["btnInfoBackground"] = "#5bc0de"; 
		bootstrap_variable_map["btnInfoBackgroundHighlight"] = "#2f96b4"; 
		// @btnInfoBackground:                 #5bc0de;
		// @btnInfoBackgroundHighlight:        #2f96b4;

		bootstrap_variable_map["btnSuccessBackground"] = "#62c462"; 
		bootstrap_variable_map["btnSuccessBackgroundHighlight"] = "#51a351"; 
		// @btnSuccessBackground:              #62c462;
		// @btnSuccessBackgroundHighlight:     #51a351;

		bootstrap_variable_map["btnWarningBackground"] = "lighten(@orange, 15%)"; 
		bootstrap_variable_map["btnWarningBackgroundHighlight"] = "@orange"; 
		// @btnWarningBackground:              lighten(@orange, 15%);
		// @btnWarningBackgroundHighlight:     @orange;

		bootstrap_variable_map["btnDangerBackground"] = "#ee5f5b"; 
		bootstrap_variable_map["btnDangerBackgroundHighlight"] = "#bd362f"; 
		// @btnDangerBackground:               #ee5f5b;
		// @btnDangerBackgroundHighlight:      #bd362f;

		bootstrap_variable_map["btnInverseBackground"] = "@gray"; 
		bootstrap_variable_map["btnInverseBackgroundHighlight"] = "@grayDarker"; 
		// @btnInverseBackground:              @gray;
		// @btnInverseBackgroundHighlight:     @grayDarker;


		// Forms
		// -------------------------
		bootstrap_variable_map["inputBackground"] = "@white"; 
		bootstrap_variable_map["inputBorder"] = "#ccc"; 
		bootstrap_variable_map["inputBorderRadius"] = "3px"; 
		bootstrap_variable_map["inputDisabledBackground"] = "@grayLighter"; 
		bootstrap_variable_map["formActionsBackground"] = "#f5f5f5"; 
		// @inputBackground:               @white;
		// @inputBorder:                   #ccc;
		// @inputBorderRadius:             3px;
		// @inputDisabledBackground:       @grayLighter;
		// @formActionsBackground:         #f5f5f5;

		// Dropdowns
		// -------------------------
		bootstrap_variable_map["dropdownBackground"] = "@white"; 
		bootstrap_variable_map["dropdownBorder"] = "rgba(0,0,0,.2)"; 
		bootstrap_variable_map["dropdownLinkColor"] = "@grayDark"; 
		bootstrap_variable_map["dropdownLinkColorHover"] = "@white"; 
		bootstrap_variable_map["dropdownLinkBackgroundHover"] = "@linkColor"; 
		bootstrap_variable_map["dropdownDividerTop"] = "#e5e5e5"; 
		bootstrap_variable_map["dropdownDividerBottom"] = "@white"; 
		// @dropdownBackground:            @white;
		// @dropdownBorder:                rgba(0,0,0,.2);
		// @dropdownLinkColor:             @grayDark;
		// @dropdownLinkColorHover:        @white;
		// @dropdownLinkBackgroundHover:   @linkColor;
		// @dropdownDividerTop:            #e5e5e5;
		// @dropdownDividerBottom:         @white;



		// COMPONENT VARIABLES
		// --------------------------------------------------

		// Z-index master list
		// -------------------------
		// Used for a bird's eye view of components dependent on the z-axis
		// Try to avoid customizing these :)
		bootstrap_variable_map["zindexDropdown"] = "1000"; 
		bootstrap_variable_map["zindexPopover"] = "1010"; 
		bootstrap_variable_map["zindexTooltip"] = "1020"; 
		bootstrap_variable_map["zindexFixedNavbar"] = "1030"; 
		bootstrap_variable_map["zindexModalBackdrop"] = "1040"; 
		bootstrap_variable_map["zindexModal"] = "1050"; 
		// @zindexDropdown:          1000;
		// @zindexPopover:           1010;
		// @zindexTooltip:           1020;
		// @zindexFixedNavbar:       1030;
		// @zindexModalBackdrop:     1040;
		// @zindexModal:             1050;


		// Sprite icons path
		// -------------------------
		bootstrap_variable_map["iconSpritePath"] = "\"../img/glyphicons-halflings.png\"";
		bootstrap_variable_map["iconWhiteSpritePath"] = "\"../img/glyphicons-halflings-white.png\"";
		// @iconSpritePath:          "../img/glyphicons-halflings.png";
		// @iconWhiteSpritePath:     "../img/glyphicons-halflings-white.png";


		// Input placeholder text color
		// -------------------------
		bootstrap_variable_map["placeholderText"] = "@grayLight"; 
		// @placeholderText:         @grayLight;


		// Hr border color
		// -------------------------
		bootstrap_variable_map["hrBorder"] = "@grayLighter"; 
		// @hrBorder:                @grayLighter;


		// Navbar
		// -------------------------
		bootstrap_variable_map["navbarHeight"] = "40px"; 
		bootstrap_variable_map["navbarBackground"] = "@grayDarker"; 
		bootstrap_variable_map["navbarBackgroundHighlight"] = "@grayDark"; 
		// @navbarHeight:                    40px;
		// @navbarBackground:                @grayDarker;
		// @navbarBackgroundHighlight:       @grayDark;

		bootstrap_variable_map["navbarText"] = "@grayLight"; 
		bootstrap_variable_map["navbarLinkColor"] = "@grayLight"; 
		bootstrap_variable_map["navbarLinkColorHover"] = "@white"; 
		bootstrap_variable_map["navbarLinkColorActive"] = "@navbarLinkColorHover"; 
		bootstrap_variable_map["navbarLinkBackgroundHover"] = "transparent"; 
		bootstrap_variable_map["navbarLinkBackgroundActive"] = "@navbarBackground"; 
		// @navbarText:                      @grayLight;
		// @navbarLinkColor:                 @grayLight;
		// @navbarLinkColorHover:            @white;
		// @navbarLinkColorActive:           @navbarLinkColorHover;
		// @navbarLinkBackgroundHover:       transparent;
		// @navbarLinkBackgroundActive:      @navbarBackground;

		bootstrap_variable_map["navbarSearchBackground"] = "lighten(@navbarBackground, 25%)"; 
		bootstrap_variable_map["navbarSearchBackgroundFocus"] = "@white"; 
		bootstrap_variable_map["navbarSearchBorder"] = "darken(@navbarSearchBackground, 30%)"; 
		bootstrap_variable_map["navbarSearchPlaceholderColor"] = "#ccc"; 
		bootstrap_variable_map["navbarBrandColor"] = "@navbarLinkColor"; 
		// @navbarSearchBackground:          lighten(@navbarBackground, 25%);
		// @navbarSearchBackgroundFocus:     @white;
		// @navbarSearchBorder:              darken(@navbarSearchBackground, 30%);
		// @navbarSearchPlaceholderColor:    #ccc;
		// @navbarBrandColor:                @navbarLinkColor;


		// Hero unit
		// -------------------------
		bootstrap_variable_map["heroUnitBackground"] = "@grayLighter"; 
		bootstrap_variable_map["heroUnitHeadingColor"] = "inherit"; 
		bootstrap_variable_map["heroUnitLeadColor"] = "inherit"; 
		// @heroUnitBackground:              @grayLighter;
		// @heroUnitHeadingColor:            inherit;
		// @heroUnitLeadColor:               inherit;


		// Form states and alerts
		// -------------------------
		bootstrap_variable_map["warningText"] = "#c09853"; 
		bootstrap_variable_map["warningBackground"] = "#fcf8e3"; 
		bootstrap_variable_map["warningBorder"] = "darken(spin(@warningBackground, -10), 3%)"; 
		// @warningText:             #c09853;
		// @warningBackground:       #fcf8e3;
		// @warningBorder:           darken(spin(@warningBackground, -10), 3%);

		bootstrap_variable_map["errorText"] = "#b94a48"; 
		bootstrap_variable_map["errorBackground"] = "#f2dede"; 
		bootstrap_variable_map["errorBorder"] = "darken(spin(@errorBackground, -10), 3%)"; 
		// @errorText:               #b94a48;
		// @errorBackground:         #f2dede;
		// @errorBorder:             darken(spin(@errorBackground, -10), 3%);

		bootstrap_variable_map["successText"] = "#468847"; 
		bootstrap_variable_map["successBackground"] = "#dff0d8"; 
		bootstrap_variable_map["successBorder"] = "darken(spin(@successBackground, -10), 5%)"; 
		// @successText:             #468847;
		// @successBackground:       #dff0d8;
		// @successBorder:           darken(spin(@successBackground, -10), 5%);

		bootstrap_variable_map["infoText"] = "#3a87ad"; 
		bootstrap_variable_map["infoBackground"] = "#d9edf7"; 
		bootstrap_variable_map["infoBorder"] = "darken(spin(@infoBackground, -10), 7%)"; 
		// @infoText:                #3a87ad;
		// @infoBackground:          #d9edf7;
		// @infoBorder:              darken(spin(@infoBackground, -10), 7%);



		// GRID
		// --------------------------------------------------

		// Default 940px grid
		// -------------------------
		bootstrap_variable_map["gridColumns"] = "12"; 
		bootstrap_variable_map["gridColumnWidth"] = "60px"; 
		bootstrap_variable_map["gridGutterWidth"] = "20px"; 
		bootstrap_variable_map["gridRowWidth"] = "(@gridColumns * @gridColumnWidth) + (@gridGutterWidth * (@gridColumns - 1))"; 
		// @gridColumns:             12;
		// @gridColumnWidth:         60px;
		// @gridGutterWidth:         20px;
		// @gridRowWidth:            (@gridColumns * @gridColumnWidth) + (@gridGutterWidth * (@gridColumns - 1));

		// Fluid grid
		// -------------------------
		bootstrap_variable_map["fluidGridColumnWidth"] = "6.382978723%"; 
		bootstrap_variable_map["fluidGridGutterWidth"] = "2.127659574%"; 
		// @fluidGridColumnWidth:    6.382978723%;
		// @fluidGridGutterWidth:    2.127659574%;

	}

}