/*
Javascript component of ubiquity-slideshow global to all variations.

* Interprets parameters passed via location.hash (in #?param1=key?param2 format)
* Creates an animated slideshow inside the #slideshow element.
* Automatically loads a requested locale, based on the default slides.
* Manages slideshow controls, if requested via parameters.

Assumptions are made about the design of the html document this is inside of.
Please see slides/ubuntu/index.html for an example of this script in use.


Dependencies (please load these first):
link-core/jquery.js
link-core/jquery.cycle.all.js
directory.js (note that this file does not exist yet, but will when the build script runs)
*/

/* Pass parameters by creating a global SLIDESHOW_OPTIONS object, containing
   any options described at <http://jquery.malsup.com/cycle/options.html>
   
   The default callback for cycle.next also checks an extra autopause parameter,
   which will pause the slideshow when it reaches the end (but doesn't stop it)
*/

var slideshow;

$(document).ready(function() {
	slideshow = $('#slideshow');
	
	var slideshow_options = {
		fx:'scrollHorz',
		timeout:45000,
		speed:500,
		nowrap:false,
		autopause:true,
		manualTrump:false,
	};
	
	
	
	var instance_options = [];
	parameters = window.location.hash.slice(window.location.hash.indexOf('#') + 1).split('?');
	for(var i = 0; i < parameters.length; i++)
	{
		hash = parameters[i].split('=');
		instance_options.push(hash[0]);
		instance_options[hash[0]] = hash[1];
	}
	
	if ( instance_options.indexOf('locale') > -1 )
		setLocale(instance_options['locale']);
	
	if ( instance_options.indexOf('rtl') > -1 )
		$(document.body).addClass('rtl');
	
	loadSlides();
	
	
	
	var debug_controls;
	if ( instance_options.indexOf('controls') > -1 )
		debug_controls = $('#debug-controls');
	var controls = $('#controls') || debug_controls;
	
	if (debug_controls) {
		debug_controls.show();
	}
	
	if (controls) {
		/* we assume #controls contains
		   #current-slide, #prev-slide and #next-slide */
		/*slideshow.options.loop = true;*/ /* TODO: USE CYCLE.NOWRAP */
		
		slideshow_options.prev = $('#prev-slide');
		slideshow_options.next = $('#next-slide');
	}
	
	
	
	slideshow_options.after = function(curr, next, opts) {
		var index = opts.currSlide;
		/* pause at last slide if requested in options */
		if ( index == opts.slideCount - 1 && opts.autopause ) {
			slideshow.cycle('pause'); /* slides can still be advanced manually */
		}
	}
	
	$.extend(slideshow_options, window.SLIDESHOW_OPTIONS);
	slideshow.cycle(slideshow_options);
});


function setLocale(locale) {
	slideshow.find('div>a').each(function() {
		var new_url = get_translated_url($(this).attr('href'), locale);
		
		if ( new_url != null ) {
			$(this).attr('href', new_url);
		}
	})
	
	function get_translated_url(slide_name, locale) {
		var translated_url = null
		
		if ( translation_exists(slide_name, locale) ) {
			translated_url = "./loc."+locale+"/"+slide_name;
		} else {
			var before_dot = locale.split(".",1)[0];
			var before_underscore = before_dot.split("_",1)[0];
			if ( before_underscore != null && translation_exists(slide_name, before_underscore) )
				translated_url = "./loc."+before_underscore+"/"+slide_name;
			else if ( before_dot != null && translation_exists(slide_name, before_dot) )
				translated_url = "./loc."+before_dot+"/"+slide_name;
		}
		
		return translated_url;
	}
	
	function translation_exists(slide_name, locale) {
		result = false;
		try {
			result = ( directory[locale][slide_name] == true );
		} catch(err) {
			/*
			This usually happens if the directory object
			(auto-generated at build time, placed in ./directory.js)
			does not exist. That object is needed to know whether
			a translation exists for the given locale.
			*/
		}
		return result;
	}
}


function loadSlides() {
	slideshow.children('div').each(function() {
		url = $(this).children('a').attr('href');
		$(this).load(url);
	});
}

