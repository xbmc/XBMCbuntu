#!/usr/bin/python

import os
from gi.repository import Gdk, Gtk, WebKit
import ConfigParser
import subprocess

import sys
import locale
from optparse import OptionParser
import gobject

'''
A basic GTK widget (WebKit.WebView) which displays a slideshow in the
ubiquity-slideshow format. Feel free to copy and paste this to your application
and customize it as needed.
'''
class SlideshowViewer(WebKit.WebView):
	'''
	@param  path  Path to the slideshow, in which the slideshow.conf file is stored.
	@param  locale  Ideal locale to use for the slideshow
	@param  rtl  True if the given locale should be displayed right-to-left
	'''
	def __init__(self, path, locale='c', rtl=False, controls=False):
		self.path = path
		
		config = ConfigParser.ConfigParser()
		config.read(os.path.join(self.path,'slideshow.conf'))
		
		self.locale = self._find_available_locale(locale)
		
		slideshow_main = 'file://' + os.path.join(self.path, 'slides', 'index.html')
		
		parameters = ''
		
		if controls:
			parameters += "?controls"
		if self.locale != 'c': #slideshow will use default automatically
			parameters += '?locale=' + self.locale
		if rtl:
			parameters += '?rtl'
		
		WebKit.WebView.__init__(self)
		self.open(slideshow_main+'#'+parameters)
		
		settings = self.get_settings()
		settings.set_property("enable-default-context-menu", False)
		#Recent webkit feature. See <http://trac.WebKit.org/changeset/52087>.
		settings.set_property("enable-file-access-from-file-uris", True)
		
		config_width = int(config.get('Slideshow','width'))
		config_height = int(config.get('Slideshow','height'))
		self.set_size_request(config_width,config_height)
		
		self.connect('navigation-policy-decision-requested', self._on_navigate_decision)
		self.connect('navigation-requested', self._on_navigate)
		self.connect('new-window-policy-decision-requested', self._on_new_window_decision)
		self.connect('create-web-view', self._on_new_window)
	
	'''
	Determines the ideal locale for the slideshow, based on the given locale,
	or 'c' if an ideal one is not available.
	@param  locale  The full locale string, for example en_AU.UTF8
	@return  The available locale which best matches the input.
	'''
	def _find_available_locale(self, locale):
		slides_dir = os.path.join(self.path, "slides")
		locale_choice = 'c'
		
		if os.path.exists( os.path.join(slides_dir, "loc."+locale) ):
			locale_choice = locale
		else:
			ll_cc = locale.split('.')[0]
			ll = ll_cc.split('_')[0]
			if os.path.exists('%s/loc.%s' % (slides_dir,ll_cc)):
				locale_choice = ll_cc
			elif os.path.exists('%s/loc.%s' % (slides_dir,ll)):
				locale_choice = ll
		
		return locale_choice
	
	
	def _new_browser_window(self, uri):
		subprocess.Popen(['xdg-open', uri], close_fds=True)
	
	def _on_navigate_decision(self, view, frame, req, action, decision):
		reason = action.get_reason()
		print(reason)
		if reason == "link-clicked":
			decision.use()
			return False
		
		decision.ignore()
		return True
	
	def _on_navigate(self, view, frame, req):
		uri = req.get_uri()
		print(uri)
		self.new_browser_window(uri)
		return True
	
	def _on_new_window_decision(self, view, frame, req, action, decision):
		uri = req.get_uri()
		decision.ignore()
		self.new_browser_window(uri)
		return True
	
	def _on_new_window(self, view, frame):
		return True


def progress_increment(progressbar, fraction):
	new_fraction = progressbar.get_fraction() + fraction
	if new_fraction > 1:
		progressbar.set_fraction(1.0)
		install_progressbar.set_text("Finished pretending to install.")
		return False
	
	progressbar.set_fraction(new_fraction)
	install_progressbar.set_text("Pretending to install... %d%%" % (new_fraction * 100))
	return True


#Main program


default_path = os.path.join( os.path.abspath(os.path.dirname(sys.argv[0])) , 'build', 'ubuntu' )

default_locale = locale.getlocale()[0]

parser = OptionParser(usage="usage: %prog [options] [slideshow]")
parser.add_option("-l", "--locale", help="LOCALE to use for the slideshow", metavar="LOCALE", default=default_locale)
parser.add_option("-r", "--rtl", action="store_true", help="use output in right-to-left format")
parser.add_option("-c", "--controls", action="store_true", help="Enable controls in the slideshow (you may need to resize the window)")
parser.add_option("-p", "--path", help="path to the SLIDESHOW which will be presented", metavar="SLIDESHOW", default=default_path)

(options, args) = parser.parse_args()
options.path = os.path.abspath(options.path)
if os.path.exists(options.path) == False:
	print("\033[91m * Please build the slideshow content first by using the make command * \033[0m")
	sys.exit()


Gdk.threads_init()

slideshow_window = Gtk.Window()
slideshow_window.set_title("Ubiquity Slideshow with Webkit")
slideshow_window.connect('destroy',Gtk.main_quit)

slideshow_container = Gtk.VBox()
slideshow_container.set_spacing(8)
slideshow_window.add(slideshow_container)

slideshow = SlideshowViewer(options.path, locale=options.locale, rtl=options.rtl, controls=options.controls)

install_progressbar = Gtk.ProgressBar()
install_progressbar.set_size_request(-1,30)
install_progressbar.set_text("Pretending to install. Please wait...")
install_progressbar.set_fraction(0)


slideshow_container.add(slideshow)
slideshow_container.add(install_progressbar)

slideshow_container.set_child_packing(install_progressbar, True, False, 0, 0)


slideshow_window.show_all()


install_timer = gobject.timeout_add_seconds(2, progress_increment, install_progressbar, 0.01)


Gtk.main()
