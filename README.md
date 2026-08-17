# SHA-256 Cryptographic Core — RTL-to-GDSII on ASAP7 7nm FinFET PDK

[![Flow](https://img.shields.io/badge/flow-RTL--to--GDSII-blue)]()
[![PDK](https://img.shields.io/badge/PDK-ASAP7%207nm-informational)]()
[![Tools](https://img.shields.io/badge/EDA-Cadence%20Genus%20%7C%20Innovus-orange)]()
[![Status](https://img.shields.io/badge/timing-closed%20%40%201.66GHz-brightgreen)]()

A full digital implementation of a **SHA-256 cryptographic core** carried through synthesis and physical design on the academic **ASAP7 7nm FinFET predictive PDK**, using **Cadence Genus** (synthesis) and **Cadence Innovus** (place & route). The flow reproduces the RTL-to-GDSII methodology taught in the Centre for Hardware Security (CHEST) Genus/Innovus tutorial series, applied end-to-end to the SHA-256 engine with pipelining and register retiming to close timing at a 1.66 GHz target.

> **Attribution:** The Tcl flow scripts, floorplanning approach, and retiming methodology follow the Centre for Hardware Security's public Genus & Innovus tutorials ([Physical Design Tutorial with Cadence Innovus](https://youtu.be/a79mtLfVx_E)). This repository documents a from-scratch re-execution of that flow on the SHA-256 module, with results specific to this run.

---

## Repository Structure

```
sha256-asap7-rtl2gdsii/
├── rtl/                         # Synthesizable Verilog source (SHA-256 core)
├── sdc/                         # Timing constraints — 1.66 GHz clock, I/O delays, transitions, fanout
├── synthesis/                   # Genus run scripts, logs, and synthesis-stage reports
│   └── genus.tcl                # elaborate -> generic -> map -> pipeline insert -> retime -> export
├── pd/                          # Innovus physical design scripts + stage outputs
├── techlef/                     # ASAP7 technology LEF (colored M2-M9 layers)
├── lef/
│   └── scaled/                  # Scaled standard cell LEF
├── lib/                         # Multi-corner Liberty (.lib) timing libraries
├── qrc/                         # QRC/Captable RC extraction rules
├── db/                          # Final design database exports
│   ├── sha256_v21.def           # Post-route DEF
│   └── sha256_v21.v             # Post-route netlist
├── docs/
│   └── screenshots/             # PnR stage screenshots
│       ├── innovus.png
│       ├── floorplan.png
│       ├── pin_plan.png
│       ├── pin_plan_output.png
│       ├── power_plan_rings.png
│       ├── power_plan_H_stripes.png
│       ├── power_plan_V_stripes.png
│       ├── placement.png
│       ├── placed_cells.png
│       ├── post_cts.png
│       ├── clock_tree.png
│       └── sroute.png
├── NOTICE                       # PDK licensing / redistribution notice
├── LICENSE
└── README.md
```

---

## Key Technical Highlights

| Aspect | Detail |
|---|---|
| **Target Design** | SHA-256 cryptographic core (64-round compression engine) |
| **PDK** | Modified ASAP7 7nm FinFET predictive PDK |
| **Target Frequency** | 1.66 GHz (602 ps clock period) |
| **Optimization Strategy** | Multi-stage pipelining + Genus automatic register retiming (`set_db retime true`) |
| **Floorplan** | 194.04 µm × 194.04 µm, 170 standard-cell rows, ~70% core density |
| **Power Grid** | Global rings and mesh stripes on **M8/M9**, standard cell follow-pin rails on **M1/M2** |
| **Routing** | Signal routing M2–M7 with ASAP7 multi-patterning/color-aware DRC handling |
| **Toolchain** | Cadence Genus (synthesis), Cadence Innovus (PnR) |

---

## Flow Architecture

```
                         ┌───────────────────────────┐
                         │        RTL SOURCE         │
                         │   sha256_core.v (Verilog) │
                         └─────────────┬─────────────┘
                                       │
                          ┌────────────▼────────────┐
                          │   CADENCE GENUS (Synth) │
                          │  elaborate → generic    │
                          │  map → PIPELINE INSERT  │
                          │  RETIME (set_db retime) │
                          └────────────┬────────────┘
                                       │  mapped netlist (.v) + SDC + SDF
                          ┌────────────▼──────────────┐
                          │     CADENCE INNOVUS       │
                          │  ┌──────────────────────┐ │
                          │  │ Floorplan (170-row)  │ │
                          │  │ Power Plan (M8–M9)   │ │
                          │  │ Placement (place_opt)│ │
                          │  │ CTS (ccopt_design)   │ │
                          │  │ Hold-fix buffering   │ │
                          │  │ Routing (M2–M7)      │ │
                          │  │ Post-route optDesign │ │
                          │  └──────────────────────┘ │
                          └────────────┬──────────────┘
                                       │
                          ┌────────────▼──────────────┐
                          │     SIGNOFF & GDSII       │
                          │  STA, DRC, LVS, GDS export│
                          └───────────────────────────┘
```

---

## PPA Results Summary

| Metric | Result |
|---|---|
| **Target Frequency** | 1.66 GHz (602 ps period) |
| **Worst Negative Slack (WNS)** | +0.020 ns to +0.029 ns (setup, PASS) |
| **Hold Slack** | +0.019 ns to +0.023 ns (PASS across corners) |
| **Total Negative Slack (TNS)** | 0 ns (no violating endpoints post-route) |
| **Die Area** | 194.04 µm × 194.04 µm |
| **Standard Cell Rows** | 170 |
| **Core Utilization / Density** | ~70% |
| **Clock Skew (post-CTS)** | < 20–30 ps across sequential sinks |
| **DRC Status** | Clean — 0 violations |
| **Routing Layers Used** | M2–M7 (signal), **M8/M9 (PG rings and stripes)** |

---

## How to Reproduce

### 1. Synthesis (Cadence Genus)

```bash
cd synthesis
genus -f run_synth.tcl -log logs/genus_synth.log
```

`run_synth.tcl` performs, in order:
1. `read_hdl rtl/sha256_core.v` → `elaborate`
2. Apply `sdc/sha256_constraints.sdc` (1.66 GHz clock)
3. `syn_generic` → `syn_map`
4. Insert pipeline registers along the message-schedule (`W[i]`) and state-update (`A–H`) paths
5. `set_db retime true; retime` — automatic register retiming
6. Export mapped netlist and reports to `synthesis/`




## Physical Design Flow — Stage Gallery

| Stage | Screenshot |
|---|---|
| Floorplan | `docs/screenshots/floorplan.png` |
| Pin Placement | `docs/screenshots/pin_plan.png`, `docs/screenshots/pin_plan_output.png` |
| Power Plan — Rings | `docs/screenshots/power_plan_rings.png` |
| Power Plan — Horizontal Stripes | `docs/screenshots/power_plan_H_stripes.png` |
| Power Plan — Vertical Stripes | `docs/screenshots/power_plan_V_stripes.png` |
| Placement | `docs/screenshots/placement.png`, `docs/screenshots/placed_cells.png` |
| Clock Tree Synthesis | `docs/screenshots/post_cts.png`, `docs/screenshots/clock_tree.png` |
| Routing | `docs/screenshots/sroute.png` |

---

## Implementation Insights: Pipelining & Retiming Breakthrough

The SHA-256 compression function iterates 64 rounds of additions, rotations, and Boolean logic (Ch, Maj, Σ0, Σ1) per block, creating a deep combinational chain when implemented as a straightforward unrolled or looped datapath. At the 1.66 GHz / 602 ps target, baseline synthesis on the ASAP7 predictive library produced severe negative slack — the combinational depth through the 64-round compression logic simply couldn't settle within one cycle.

**Stage 1 — Manual Pipeline Insertion**
Registers were inserted along the two dominant critical-path structures:
- The **message schedule expander** (`W[i]` generation, which depends on `W[i-2]`, `W[i-7]`, `W[i-15]`, `W[i-16]`)
- The **state update accumulators** (`A` through `H`), where each round's Ch/Maj/Σ computations feed the next round's inputs

This broke the 64-round chain into shorter combinational segments, restoring general timing feasibility.

**Stage 2 — Automatic Register Retiming (Genus `retime`)**
Manual pipelining alone leaves stage boundaries unbalanced — some pipeline stages end up combinationally heavier than others. Enabling `set_db retime true` let Genus move flip-flops across gate boundaries (through AND/OR/XOR trees and the ripple-style adder chains in the state update) to **equalize delay per stage** rather than relying on where registers were manually placed.

This retiming pass delivered three compounding effects:
1. **Timing:** WNS moved from deeply negative to positive slack at 1.66 GHz by balancing stage delay rather than just shortening the longest path.
2. **Area:** Because retiming redistributes *existing* flip-flops rather than adding buffering or duplicate logic to force timing closure, area overhead stayed minimal relative to a brute-force buffer-tree fix.
3. **Power:** Shorter, more balanced combinational stages reduced glitch propagation through the deep XOR/adder trees, lowering dynamic switching power.

The combination of targeted manual pipelining (informed by data-dependency structure of the SHA-256 round function) followed by automatic retiming (informed by gate-level delay balancing) is what closed timing cleanly at the 1.66 GHz target while holding hold-slack, area, and DRC all within clean bounds through the Innovus PnR stages.

---

## Notes on the PDK

The ASAP7 PDK is an academic/predictive 7nm FinFET PDK (Arizona State University / ARM) intended for research and education, **not for tape-out**. Technology LEFs, standard cell LEFs, and Liberty files are not redistributed in this repository per ASAP7's usage terms — see `NOTICE` for how to obtain them and regenerate `pdk/asap7/`.

## License

Source RTL and Tcl scripts are released under the license in `LICENSE`. PDK files are excluded — see `NOTICE`.
