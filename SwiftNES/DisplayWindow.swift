//
//  DisplayWindow.swift
//  SwiftNES
//
//  Created by Adam Gastineau on 4/15/16.
//  Copyright © 2016 Adam Gastineau. All rights reserved.
//

import Cocoa

final class DisplayWindow: NSWindow {
	var controllerIO: MacControllerIO?
	
	override func keyDown(with theEvent: NSEvent) {
		controllerIO?.buttonPressEvent(Int(theEvent.keyCode))
	}
	
	override func keyUp(with theEvent: NSEvent) {
		controllerIO?.buttonUpEvent(Int(theEvent.keyCode))
	}
}
