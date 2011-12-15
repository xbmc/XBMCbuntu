#!/usr/bin/python
# -*- coding: utf-8 -*-

import os, sys
import ConfigParser

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *
from PyQt4 import uic

base_directory = os.path.dirname (sys.argv[0])
slideshow_path = os.path.abspath(base_directory + "/slideshows")

slideshow_config = ConfigParser.ConfigParser()
slideshow_config.read(os.path.join(slideshow_path,'kubuntu/slideshow.conf'))

config_width = int(slideshow_config.get('Slideshow','width'))
config_height = int(slideshow_config.get('Slideshow','height'))

ui = None
updateTimer = QTimer()

def progress_increment():
    newVal = ui.progressBar.value() + 1
    if newVal >= 100:
        ui.progressBar.setValue(100)
        updateTimer.timeout.disconnect(progress_increment)
        return
    
    ui.progressBar.setValue(newVal)
    return True
    
def openLink(qUrl):
    QDesktopServices.openUrl(qUrl)

if __name__ == "__main__":
    app = QApplication(sys.argv)

    ui = uic.loadUi(os.path.join(base_directory, "slideshow.ui"))
    
    ui.progressBar.setValue(0)
    ui.progressBar.setFormat("Fake install... %p% complete")
    
    ui.webView.setMinimumSize(config_width, config_height)
    ui.webView.linkClicked.connect(openLink)
    
    ui.webView.setContextMenuPolicy(Qt.NoContextMenu)
    ui.webView.page().setLinkDelegationPolicy(QWebPage.DelegateExternalLinks)
    ui.webView.page().mainFrame().setScrollBarPolicy(Qt.Horizontal, Qt.ScrollBarAlwaysOff)
    ui.webView.page().mainFrame().setScrollBarPolicy(Qt.Vertical, Qt.ScrollBarAlwaysOff)
    
    ui.webView.load(QUrl(os.path.join(slideshow_path, "kubuntu", "slides", "index.html")))
    
    ui.setWindowTitle("Ubiquity Slideshow with Webkit")
    ui.show()
    
    updateTimer.timeout.connect(progress_increment)
    updateTimer.start(2000)

    app.exec_()
