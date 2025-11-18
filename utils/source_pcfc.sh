#!/bin/bash
# Source script for PCFC modular architecture
# Updated for organized directory structure

# Get the base directory (assuming this script is in ~/usr/pcfc/)
PCFC_BASE="$HOME/usr/pcfc"

# ============================================================================
# BIN - Main executables
# ============================================================================
source $PCFC_BASE/bin/binary_search_coexistence
source $PCFC_BASE/bin/check_coexistence
source $PCFC_BASE/bin/main_exe
source $PCFC_BASE/bin/run_coexistence

# ============================================================================
# CALCULATORS - Property calculation scripts
# ============================================================================
source $PCFC_BASE/calculators/calc_atom
source $PCFC_BASE/calculators/calc_correction
source $PCFC_BASE/calculators/calc_energy
source $PCFC_BASE/calculators/calc_energy_block
source $PCFC_BASE/calculators/calc_msd
source $PCFC_BASE/calculators/calc_pressure
source $PCFC_BASE/calculators/calc_pressure_block
source $PCFC_BASE/calculators/calc_temperature
source $PCFC_BASE/calculators/calc_temperature_block
source $PCFC_BASE/calculators/calc_volume
source $PCFC_BASE/calculators/calc_tpe
# source $PCFC_BASE/calculators/calc_avg_freq  # Uncomment if needed

# ============================================================================
# SAMPLING - MD and configuration sampling
# ============================================================================
source $PCFC_BASE/sampling/run_md
source $PCFC_BASE/sampling/sample_md_coex
source $PCFC_BASE/sampling/sample_ti_configs
# source $PCFC_BASE/sampling/sample_md_lambda1  # Uncomment if needed

# ============================================================================
# EOS - Equation of state fitting
# ============================================================================
source $PCFC_BASE/eos/calc_vp_scan
source $PCFC_BASE/eos/fit_eos_coex

# ============================================================================
# ANALYSIS - Data extraction and plotting
# ============================================================================
source $PCFC_BASE/analysis/extract_and_density
source $PCFC_BASE/analysis/extract_data
source $PCFC_BASE/analysis/plot_convergence
source $PCFC_BASE/analysis/plot_fittings
# source $PCFC_BASE/analysis/run_block_error  # Uncomment if needed

# ============================================================================
# UTILS - Utility and helper scripts
# ============================================================================
source $PCFC_BASE/utils/check_pipeline_status
source $PCFC_BASE/utils/convert_xdatcar
source $PCFC_BASE/utils/pipeline_ref
source $PCFC_BASE/utils/show_pipeline_help
source $PCFC_BASE/utils/write_incar
source $PCFC_BASE/utils/display_banner
# source $PCFC_BASE/utils/phase_rename  # Uncomment if needed

# ============================================================================
# ML - Machine learning density classifier
# ============================================================================
source $PCFC_BASE/ml/classify_density

# ============================================================================
# Export PCFC base directory for use in scripts
# ============================================================================
export PCFC_BASE

echo "PCFC modular environment loaded from $PCFC_BASE"
