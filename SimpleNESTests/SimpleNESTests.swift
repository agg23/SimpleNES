//
//  SimpleNESTests.swift
//  SimpleNESTests
//
//  Created by Adam Gastineau on 3/23/16.
//  Copyright © 2016 Adam Gastineau. All rights reserved.
//

import XCTest
@testable import SimpleNES

let defaultPath = "/Users/adam/testROMs/";

class SimpleNESTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func romTest(path: String, testAddress: Int, desiredResult: UInt8, intermediary: UInt8, maxInstructions: Int) {
		let logger = Logger(path: "/Users/adam/nestest.log");
		
		let controllerIO = ControllerIO();
		
		let mainMemory = Memory();
		mainMemory.controllerIO = controllerIO;
		
		let ppuMemory = Memory(memoryType: Memory.MemoryType.PPU);
		let fileIO = FileIO(mainMemory: mainMemory, ppuMemory: ppuMemory);
		XCTAssert(fileIO.loadFile(path));
		
		let ppu = PPU(cpuMemory: mainMemory, ppuMemory: ppuMemory);
		
		mainMemory.ppu = ppu;
		
		let cpu = CPU(mainMemory: mainMemory, ppu: ppu, logger: logger);
		ppu.cpu = cpu;
		
		cpu.reset();
		
		var intermediaryFound = false;
		
		var instructionCount = 0;
		
		var cpuCycles = cpu.step();
		
		while(cpuCycles != -1) {
			if(instructionCount > maxInstructions) {
				XCTAssertGreaterThan(maxInstructions, instructionCount);
				return;
			}
			
			if(cpu.errorOccured) {
				XCTAssert(!cpu.errorOccured);
				return;
			}
			
			let result = mainMemory.readMemory(testAddress);
			
			if(result == intermediary) {
				intermediaryFound = true;
			} else if(intermediaryFound && result != intermediary) {
				XCTAssertEqual(result, desiredResult);
				return;
			}
			
			for _ in 0 ..< cpuCycles * 3 {
				ppu.step();
			}
			
			instructionCount += 1;
			
			cpuCycles = cpu.step();
		}
		
		XCTAssertNotEqual(cpuCycles, -1);
	}
	
	// MARK: - CPU Instruction Testing
	
	// MARK: - blargg's CPU Behavior Instruction Tests
	
	func testCPUBasics() {
		romTest(defaultPath + "instr_test-v5/rom_singles/01-basics.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testImplied() {
		romTest(defaultPath + "instr_test-v5/rom_singles/02-implied.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testImmediate() {
		romTest(defaultPath + "instr_test-v5/rom_singles/03-immediate.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testZeroPage() {
		romTest(defaultPath + "instr_test-v5/rom_singles/04-zero_page.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testZeroPageXY() {
		romTest(defaultPath + "instr_test-v5/rom_singles/05-zp_xy.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testAbsolute() {
		romTest(defaultPath + "instr_test-v5/rom_singles/06-absolute.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testAbsoluteXY() {
		romTest(defaultPath + "instr_test-v5/rom_singles/07-abs_xy.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testIndirectX() {
		romTest(defaultPath + "instr_test-v5/rom_singles/08-ind_x.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testIndirectY() {
		romTest(defaultPath + "instr_test-v5/rom_singles/09-ind_y.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testBranches() {
		romTest(defaultPath + "instr_test-v5/rom_singles/10-branches.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testStack() {
		romTest(defaultPath + "instr_test-v5/rom_singles/11-stack.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testJump() {
		romTest(defaultPath + "instr_test-v5/rom_singles/12-jmp_jsr.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testRTS() {
		romTest(defaultPath + "instr_test-v5/rom_singles/13-rts.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testRTI() {
		romTest(defaultPath + "instr_test-v5/rom_singles/14-rti.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testBRK() {
		romTest(defaultPath + "instr_test-v5/rom_singles/15-brk.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testSpecialInstructions() {
		romTest(defaultPath + "instr_test-v5/rom_singles/16-special.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	// MARK: - Instruction Timing
	
	func testInstructionTiming() {
		// Needs implemented APU
		romTest(defaultPath + "instr_timing/rom_singles/1-instr_timing.nes ", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testBranchTiming() {
		// Needs implemented APU
		romTest(defaultPath + "instr_timing/rom_singles/2-branch_timing.nes ", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	// MARK: - Instruction Execution from Any Address
	
	func testCPUExecSpace() {
		romTest(defaultPath + "cpu_exec_space/test_cpu_exec_space_ppuio.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	// MARK: - Interrupts
	
	func testCLILatency() {
		// Needs implemented APU
		romTest(defaultPath + "cpu_interrupts_v2/rom_singles/1-cli_latency.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testNMIBRK() {
		romTest(defaultPath + "cpu_interrupts_v2/rom_singles/2-nmi_and_brk.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testNMIIRQ() {
		romTest(defaultPath + "cpu_interrupts_v2/rom_singles/3-nmi_and_irq.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testIRQDMA() {
		romTest(defaultPath + "cpu_interrupts_v2/rom_singles/4-irq_and_dma.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testBranchDelaysIRQ() {
		romTest(defaultPath + "cpu_interrupts_v2/rom_singles/5-branch_delays_irq.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	// MARK: - Dummy Read Testing
	
	func testABSWrap() {
		romTest(defaultPath + "instr_misc/rom_singles/01-abs_x_wrap.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
    
	func testBranchWrap() {
		romTest(defaultPath + "instr_misc/rom_singles/02-branch_wrap.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testDummyReads() {
		romTest(defaultPath + "instr_misc/rom_singles/03-dummy_reads.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testDummyReadsAPU() {
		// Needs implemented APU
		romTest(defaultPath + "instr_misc/rom_singles/04-dummy_reads_apu.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	// MARK: - PPU Testing
	
	func testOAMRead() {
		romTest(defaultPath + "oam_read/oam_read.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testOAMStress() {
		romTest(defaultPath + "oam_stress/oam_stress.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testPPUOpenBus() {
		romTest(defaultPath + "ppu_open_bus/ppu_open_bus.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	// Blargg's PPU tests cannot be automated
	// Fails Power Up Palette (expected)
	// Fails Sprite RAM #4
	// Fails VRAM Access #3 (VBL cleared too late)
	// Passes all others
	
	// Sprite hit tests cannot be automated.
	// Fails Screen Bottom #4
	// Fails Timing Basics with black screen
	// Fails Timing Order with black screen
	// Fails Edge Timing with black screen
	// Black screens possibly need implemented APU
	// Passes all others
	
	// MARK: - VBlank flag and NMI Testing
	
	func testVBLBasics() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/01-vbl_basics.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testVBLSetTiming() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/02-vbl_set_time.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testVBLClearTiming() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/03-vbl_clear_time.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testNMIControl() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/04-nmi_control.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testNMITiming() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/05-nmi_timing.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testVBLSupression() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/06-suppression.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testNMINearVBLClear() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/07-nmi_on_timing.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testNMINearVBLSet() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/08-nmi_off_timing.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testEvenOddFrameSkipping() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/09-even_odd_frames.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}
	
	func testEvenOddFrameTiming() {
		romTest(defaultPath + "ppu_vbl_nmi/rom_singles/10-even_odd_timing.nes", testAddress: 0x6000, desiredResult: 0x00, intermediary: 0x80, maxInstructions: 5000000);
	}

	
}
