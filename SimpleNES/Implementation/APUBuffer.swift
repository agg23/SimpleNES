//
//  APUBuffer.swift
//  SimpleNES
//
//  Created by Adam Gastineau on 5/10/16.
//  Copyright © 2016 Adam Gastineau. All rights reserved.
//

import Foundation
import AudioToolbox

final class APUBuffer {
	private let BUFFERSIZE = 500000;
	// 31250
	private let IDEALCAPACITY = 500000 * 0.7;
	private let CPUFREQENCY = 1789773.0;
	private let SAMPLERATE = 44100.0;
	private let SAMPLERATEDIVISOR = 1789773.0 / 44100.0;
	private let ALPHA = 0.000005;
	private let FILLBUFFERCOUNT = 60;
	
	private var fillBuffer: [Int];
	private var fillBufferIndex: Int;
	private var buffer: [Int16];
	private var startIndex: Int;
	private var endIndex: Int;
	
	private var rollingSamplesToGet: Double;
	
	private var currentSampleRate: Double;
	
	init() {
		self.fillBuffer = [Int](count: FILLBUFFERCOUNT, repeatedValue: Int(IDEALCAPACITY));
		self.fillBufferIndex = 0;
		
		self.buffer = [Int16](count: BUFFERSIZE, repeatedValue: 0);
		
		self.startIndex = 0;
		self.endIndex = Int(IDEALCAPACITY);
		
		self.currentSampleRate = Double(SAMPLERATE);
		
		self.rollingSamplesToGet = SAMPLERATEDIVISOR;
	}
	
	func linearRegression() -> Double {
		var sumX = 0;
		var sumY = 0;
		var sumXY = 0;
		var sumXSquared = 0;
		var sumYSquared = 0;
		
		for i in 0 ..< FILLBUFFERCOUNT {
			let y = self.fillBuffer[i];
			sumX = sumX + i;
			sumY = sumY + y;
			sumXY = sumXY + i * y;
			sumXSquared = sumXSquared + i * i;
			sumYSquared = sumYSquared + y * y;
		}
		
		let slope = Double(FILLBUFFERCOUNT * sumXY - sumX * sumY) / Double(FILLBUFFERCOUNT * sumXSquared - sumX * sumX);
		
		return slope;
	}
	
	func updateRegression() {
		let count = availableSampleCount();
		fillBuffer[self.fillBufferIndex] = count;
		
		self.fillBufferIndex += 1;
		
		if(self.fillBufferIndex >= FILLBUFFERCOUNT) {
			self.fillBufferIndex = 0;
		}
	}
	
	func availableSampleCount() -> Int {
		if(self.endIndex < self.startIndex) {
			return BUFFERSIZE - self.startIndex + self.endIndex;
		}
		
		return self.endIndex - self.startIndex;
	}
	
	func saveSample(sampleData: Int16) {
		self.buffer[self.endIndex] = sampleData;
		
		self.endIndex += 1;
		
//		print(availableSampleCount());
		
		if(self.endIndex >= BUFFERSIZE) {
			self.endIndex = 0;
		}
		
		if(self.startIndex == self.endIndex) {
			print("Buffer overflow");
		}
	}
	
	func loadBuffer(audioBuffer: AudioQueueBufferRef) {
		let array = UnsafeMutablePointer<Int16>(audioBuffer.memory.mAudioData);
		
		let size = Int(audioBuffer.memory.mAudioDataBytesCapacity / 2);
		
//		// Give a 20% tolerence for correction
//		let originalTransferSize = Double(size) / 1.5;
//
//		let sampleCount =
		
		
//		print(capacityModifier);
		
//		if(capacityModifier > 1.03) {
//			capacityModifier = 1.03;
//			print("Increasing");
//		} else if(capacityModifier < 0.97) {
//			print("Decreasing");
//			capacityModifier = 0.97;
//		}
		
//		let finalSampleCount = Int(originalTransferSize * capacityModifier);
//		let samplesToGet = Int(SAMPLERATEDIVISOR * capacityModifier);
//		print("Count: \(availableSampleCount()), Start: \(self.startIndex), End: \(self.endIndex)");
		
		let sampleCount = Double(availableSampleCount());
		let sampleDelta = sampleCount - IDEALCAPACITY;
		
		updateRegression();
		
		let slope = linearRegression();
		
		var capacityModifier = 0.0;
		
		if((slope > 1 && sampleDelta < 0) || (slope < -1 && sampleDelta > 0)) {
			capacityModifier = fabs(slope)/4.0;
			
//			if(capacityModifier > 1) {
//				capacityModifier = 1;
//			} else if(capacityModifier < -1) {
//				capacityModifier = -1;
//			}
		} else if((slope > 0 && sampleDelta > 0) || (slope < 0 && sampleDelta < 0)) {
			let skew = sampleDelta / Double(size) * 20.0;
			
			capacityModifier = (fabs(slope) + skew) / 2.0;
			
//			if(capacityModifier > 2) {
//				capacityModifier = 2;
//			} else if(capacityModifier < -2) {
//				capacityModifier = -2;
//			}
		}
		
		let samplesToGet = Int(CPUFREQENCY / (SAMPLERATE + capacityModifier));
		
		print("Slope \(slope) Capacity \(capacityModifier) Samples \(samplesToGet)");
		
		for i in 0 ..< size {
//			var capacityModifier = sampleCount / IDEALCAPACITY;
			
//			if(capacityModifier > 1.03) {
//				capacityModifier = 1.03;
////				print("Increasing");
//			} else if(capacityModifier < 0.97) {
////				print("Decreasing");
//				capacityModifier = 0.97;
//			}
//			
			
			
			array[i] = normalizedSample(samplesToGet);
			
			if(self.startIndex + samplesToGet >= BUFFERSIZE) {
				self.startIndex = self.startIndex + samplesToGet - BUFFERSIZE;
			} else {
				self.startIndex += samplesToGet;
			}
			
			if(self.startIndex == self.endIndex) {
				print("Buffer underflow");
			}
		}
		
//		print(availableSampleCount());
		
		audioBuffer.memory.mAudioDataByteSize = UInt32(size * 2);
	}
	
	func normalizedSample(sampleCount: Int) -> Int16 {
		var accumulator: Int = 0;
		
		for i in 0 ..< sampleCount {
			let index = (self.startIndex + i) % BUFFERSIZE;
			accumulator += Int(self.buffer[index]);
		}
		
		return Int16(accumulator / sampleCount);
	}
}