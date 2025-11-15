==================================================
PCFC - Phase Coexistence Free Energy Calculator
==================================================

.. image:: https://img.shields.io/badge/License-MIT-blue.svg
   :target: https://opensource.org/licenses/MIT
   :alt: License: MIT

.. image:: https://img.shields.io/badge/Bash-5.0+-green.svg
   :target: https://www.gnu.org/software/bash/
   :alt: Bash

.. image:: https://img.shields.io/badge/VASP-5.4%2B-orange.svg
   :target: https://www.vasp.at/
   :alt: VASP

.. image:: https://img.shields.io/badge/Status-Active-success.svg
   :alt: Status: Active

.. image:: https://img.shields.io/badge/Python-3.8+-blue.svg
   :target: https://www.python.org/
   :alt: Python

**Automated workflow for solid-liquid coexistence determination and free energy calculations using VASP DFT and thermodynamic integration.**

Overview
========

PCFC automates the computation of melting points and phase equilibria through binary search coexistence algorithms coupled with thermodynamic integration (TI). It combines molecular dynamics simulations, equation-of-state fitting, and machine learning-based phase classification to calculate Gibbs free energy corrections.

Architecture
============

::

    pcfc/
    ├── bin/                    # Core workflow executables
    │   ├── main_exe           # Main coexistence search driver
    │   ├── binary_search_coexistence
    │   ├── check_coexistence  # Phase state detector
    │   └── run_coexistence    # Single-point coexistence runner
    ├── calculators/           # Thermodynamic property calculators
    │   ├── calc_temperature   # Temperature from OSZICAR
    │   ├── calc_pressure      # Pressure from OUTCAR
    │   ├── calc_energy        # Internal energy
    │   ├── calc_enthalpy      # Enthalpy/entropy
    │   └── calc_*_block       # Block averaging for error analysis
    ├── sampling/              # MD trajectory sampling
    │   ├── sample_md_coex     # NPT equilibration at coexistence
    │   ├── sample_ti_configs  # Configuration extraction for TI
    │   └── run_md             # Generic MD runner
    ├── eos/                   # Equation of state fitting
    │   ├── calc_vp_scan       # Volume-pressure scan
    │   └── fit_eos_coex       # Birch-Murnaghan EOS fitting
    ├── analysis/              # Post-processing tools
    │   ├── extract_and_density # Density profile extraction
    │   ├── plot_convergence   # Convergence diagnostics
    │   └── run_block_error    # Statistical error analysis
    ├── ml/                    # Machine learning classifiers
    │   ├── classify_density.py # Phase identification
    │   └── models/            # Pre-trained classifiers
    ├── utils/                 # Pipeline utilities
    │   ├── check_pipeline_status
    │   ├── show_pipeline_help
    │   └── write_incar        # VASP input generator
    └── example/               # Example workflows
        ├── pipeline.sh        # Full pipeline script
        ├── POSCAR.coex        # Coexistence supercell
        └── POSCAR.s           # Single-phase cell

Quick Start
===========

Prerequisites
-------------
- VASP 5.4+ compiled with MPI
- Bash 5.0+
- Python 3.8+ with scikit-learn, numpy
- BC calculator, ASE (optional)

Installation
------------

.. code-block:: bash

   git clone https://github.com/shambhuphysics/PCFC-Automation.git
   cd pcfc
   source source.sh  # Load environment

Basic Usage
-----------

.. code-block:: bash

   cd example
   ./pipeline.sh  # Run full coexistence + TI workflow

**Configuration**: Edit ``config/coexistence.conf`` to set:

- ``ELEMENT``, ``ATOMIC_MASS``
- ``TEMP_MIN``, ``TEMP_MAX``, ``TEMP_TOLERANCE``
- ``VOLUME_COEX``, ``COEX_ATOMS``
- TI parameters (``TI_ATOMS``, ``KPOINTS``)

Workflow Stages
===============

Stage 1: Coexistence Search
----------------------------
Binary search algorithm identifies solid-liquid coexistence temperature within specified tolerance.

Stage 2: Free Energy Correction
--------------------------------
1. **VP Scan**: Volume-pressure relation at coexistence
2. **EOS Fit**: Birch-Murnaghan equation fitting
3. **MD Sampling**: NPT trajectory generation
4. **TI Calculation**: EAM and DFT thermodynamic integration

Output Files
============
- ``coex_results.dat``: Coexistence T, P, V
- ``VP.dat``, ``VP_plot.png``: EOS data
- ``XDATCAR.s``: MD trajectories
- ``s*EAM/``, ``s*DFT/``: TI calculation directories

Citation
========
If you use PCFC in your research, please cite:

.. code-block:: bibtex

   @software{pcfc2024,
     author = {Sharma, Shambhu Bhandari},
     title = {PCFC: Phase Coexistence Free Energy Calculator},
     year = {2024},
     url = {https://github.com/shamphuphysics/pcfc}
   }

Contributing
============
Contributions welcome! Please follow:

- Modular function design (single responsibility)
- Configuration-driven parameters (no hardcoding)
- Standard bash error handling (``set -euo pipefail``)
- Descriptive logging with severity levels

License
=======
MIT License - see LICENSE file [attached_file:1]

Author
======
**Shambhu Bhandari Sharma**

University College London

📧 ucfbsbh.22@ucl.ac.uk

Acknowledgments
===============
Developed as part of PhD research in computational materials science at UCL.
