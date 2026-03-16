
# Sync FIFO IP – Configuration, Verification and Resource Utilization

This document summarizes the **default parameters, supported operating modes, and FPGA resource utilization** for the **Synchronous FIFO IP**.

The implementation and timing results were generated using **Efinity targeting the Efinix Trion FPGA family**.

---

# Contents

* [Default Parameters](#default-parameters)
* [FIFO Depth Requirement](#fifo-depth-requirement)
* [FPGA Resource Utilization](#fpga-resource-utilization)
* [Timing Results](#timing-results)

---

# Default Parameters

If parameters are not specified during instantiation, the FIFO uses the following defaults:

```
parameter TB_DEPTH = 8;
parameter TB_DATA_WIDTH = 8;
parameter TB_PROG_EMPTY_VALUE = (TB_DEPTH/2) + 1;
parameter TB_PROG_FULL_VALUE  = (TB_DEPTH/2) - 1;
parameter TB_MODE = 1;
```

### Parameter Description

**TB_DEPTH**

Total number of entries stored in the FIFO.

**TB_DATA_WIDTH**

Width of each data word stored in the FIFO.

**TB_PROG_EMPTY_VALUE**

Threshold used to assert the `prog_empty` signal.

```
Default = (DEPTH/2) + 1
```

**TB_PROG_FULL_VALUE**

Threshold used to assert the `prog_full` signal.

```
Default = (DEPTH/2) - 1
```


**TB_MODE**

```
TB_MODE = 1 → Normal FIFO Mode
TB_MODE = 0 → FWFT (First Word Fall Through)
```

Explanation:

```
MODE = 1
Data appears at the output only after read enable (r_en) is asserted.
```

```
MODE = 0
Data automatically appears at the output without requiring r_en.
This behavior is called First Word Fall Through (FWFT).
```

---

# FIFO Depth Requirement

FIFO depth should be **a power of two**.

Valid examples:

```
2, 4, 8, 16, 32, 64, 128, ...
```

### Reason

The FIFO pointer logic uses **binary pointer wrap-around detection** for full and empty conditions.
Using depths that are **powers of two simplifies address wrapping and pointer comparison logic**.

---

# FPGA Resource Utilization

Resource utilization depends on **FIFO depth and data width**.



# Configuration 1 (Default Repository Configuration)

```
DEPTH      = 8
DATA_WIDTH = 8
Clock      = 100 MHz
```

| Resource       | Used | Available |
| -------------- | ---- | --------- |
| Logic Elements | 142  | 112128    |
| Memory Blocks  | 0    | 1056      |
| Multipliers    | 0    | 320       |

### Note

For **small FIFO sizes**, synthesis tools implement FIFO storage using **flip-flops (registers)** instead of block RAM.

Therefore:

```
Memory Blocks Used = 0
```

# Configuration 2 (Large FIFO)

```
DEPTH      = 16384
DATA_WIDTH = 64
Clock      = 100 MHz
```

| Resource       | Used | Available |
| -------------- | ---- | --------- |
| Logic Elements | 320  | 112128    |
| Memory Blocks  | 256   | 1056      |
| Multipliers    | 0    | 320       |

For larger FIFO configurations the synthesis tool automatically maps storage into **embedded FPGA block RAM (BRAM)**.

This significantly reduces logic utilization compared to register-based storage.

---

# Timing Results


# Configuration 1 (Default Repository Configuration)

```
DEPTH      = 8
DATA_WIDTH = 8
Clock      = 100 MHz
```

| Metric                     | Value    |
| -------------------------- | -------- |
| Worst Negative Slack (WNS) | 3.475 ns |
| Worst Hold Slack (WHS)     | 0.309 ns |

Maximum achievable frequency:

| Clock | Maximum Frequency |
| ----- | ----------------- |
| clk   | 153.257 MHz       |

This configuration provides **~3.4 ns positive timing margin** when operating at **100 MHz**.

---

# Configuration 2

```
DEPTH      = 16384
DATA_WIDTH = 64
Clock      = 100 MHz
```

| Metric                     | Value    |
| -------------------------- | -------- |
| Worst Negative Slack (WNS) | 1.842 ns |
| Worst Hold Slack (WHS)     | 0.307 ns |

Maximum achievable frequency:

| Clock | Maximum Frequency |
| ----- | ----------------- |
| clk   | 122.579 MHz       |

This configuration also meets timing requirements with **positive slack at 100 MHz operation**.

---

Clock constraints can be modified using the **Interface Designer / timing constraint settings** in the FPGA tool.

