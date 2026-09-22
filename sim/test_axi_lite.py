import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def axi_write(dut, addr, data):
    """Helper task to perform an AXI-Lite write transaction"""
    await RisingEdge(dut.clk)
    dut.s_axi_awaddr.value = addr
    dut.s_axi_awvalid.value = 1
    dut.s_axi_wdata.value = data
    dut.s_axi_wstrb.value = 0xF
    dut.s_axi_wvalid.value = 1
    dut.s_axi_bready.value = 1

    while True:
        await RisingEdge(dut.clk)
        if dut.s_axi_awready.value and dut.s_axi_awvalid.value:
            dut.s_axi_awvalid.value = 0
        if dut.s_axi_wready.value and dut.s_axi_wvalid.value:
            dut.s_axi_wvalid.value = 0
        if dut.s_axi_bvalid.value and dut.s_axi_bready.value:
            break

    dut.s_axi_bready.value = 0

async def axi_read(dut, addr):
    """Helper task to perform an AXI-Lite read transaction"""
    await RisingEdge(dut.clk)
    dut.s_axi_araddr.value = addr
    dut.s_axi_arvalid.value = 1
    dut.s_axi_rready.value = 1

    read_data = 0
    while True:
        await RisingEdge(dut.clk)
        if dut.s_axi_arready.value and dut.s_axi_arvalid.value:
            dut.s_axi_arvalid.value = 0
        if dut.s_axi_rvalid.value and dut.s_axi_rready.value:
            read_data = int(dut.s_axi_rdata.value)
            break

    dut.s_axi_rready.value = 0
    return read_data

@cocotb.test()
async def test_axi_lite_register_access(dut):
    """Test AXI-Lite write and read back across multiple register addresses"""
    
    # Start a 10ns clock
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize signals
    dut.rst_n.value = 0
    dut.s_axi_awaddr.value = 0
    dut.s_axi_awvalid.value = 0
    dut.s_axi_wdata.value = 0
    dut.s_axi_wstrb.value = 0
    dut.s_axi_wvalid.value = 0
    dut.s_axi_bready.value = 0
    dut.s_axi_araddr.value = 0
    dut.s_axi_arvalid.value = 0
    dut.s_axi_rready.value = 0

    # Reset sequence
    await Timer(20, unit="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Test Data map
    test_cases = {
        0x0: 0xDEADBEEF,
        0x4: 0xCAFEBABE,
        0x8: 0x12345678,
        0xC: 0x87654321
    }

    # Perform Writes
    for addr, data in test_cases.items():
        print(f"Writing {hex(data)} to Address {hex(addr)}")
        await axi_write(dut, addr, data)

    # Perform Reads and Verify Data Integrity
    for addr, expected_data in test_cases.items():
        read_val = await axi_read(dut, addr)
        print(f"Reading Address {hex(addr)} -> Got: {hex(read_val)}, Expected: {hex(expected_data)}")
        assert read_val == expected_data, f"Mismatch at addr {hex(addr)}! Expected {hex(expected_data)}, got {hex(read_val)}"

    print("\n>>> SUCCESS: All AXI-Lite protocol verification assertions passed cleanly! <<<\n")
