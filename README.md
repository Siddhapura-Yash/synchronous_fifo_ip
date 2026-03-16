# Synchronous FIFO IP

A **parameterizable synchronous FIFO IP** implemented in Verilog for reliable data buffering within a **single clock domain**.
The design uses **binary read/write pointers and simple full/empty detection logic** to manage FIFO storage efficiently.

---

## Repository Structure

```
synchronous_fifo_ip/
│
├── rtl/    → FIFO IP RTL
├── sim/    → FIFO testbench
├── docs/   → IP documentation
│
├── examples/
│   └── synchronous_fifo_with_uart/
│       ├── rtl/
│       ├── sim/
│       ├── docs/
│       └── scripts/
│
└── README.md
```

---

## Documentation

* [Sync FIFO Configuration, Resource Utilization and Timing Results](docs/README.md)

* [UART ↔ Sync FIFO Loopback Hardware Test](example/synchronous_fifo_with_uart/README.md)

---

## Simulation

Run simulation from the `sim` directory:

```
cd sim
make run
```

---

## Hardware Verification

UART loopback testing script:

```
scripts/send.py
```

Run:

```
python3 scripts/send.py
```

---

## Additional Documentation

For script usage and configuration see:
[script README](example/synchronous_fifo_with_uart/scripts/README.md)

For FIFO configuration, FPGA resource utilization and timing results see:
[Configuration & timing README](docs/README.md)
