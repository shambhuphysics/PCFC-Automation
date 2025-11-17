#!/bin/bash -l
set -euo pipefail
source /home/ucfbsbh/usr/pcfc/utils/source_pcfc.sh
source ~/project/bin/activate
#===============================================================================
# Coexistence Input Variables
#===============================================================================
ELEMENT="Mg"; ATOMIC_MASS=24.305
COEX_ATOMS=8788
THERM_STEPS=5000
NVE_STEPS=25000
TEMP_MELT=12000

# Single target temperature with 200K range
TARGET_TCOEX=1500  #for serial , set your vlume 
TEMP_RANGE=1500
TEMP_MIN=$((TARGET_TCOEX - TEMP_RANGE))  # 900K
TEMP_MAX=$((TARGET_TCOEX + TEMP_RANGE))  # 1100K
TEMP_TOLERANCE=10

# Choose Volume of Supercell
VOLUME_COEX=196274   # for serial , set your vlume 

#===============================================================================
# Free Energy Correction Variables
#===============================================================================
TI_ATOMS=432
TI_THERM_STEPS_VP=100000
TI_THERM_STEPS=300000
VP_NUM_POINTS=12
KPOINTS="2 2 2"
TI_START_FRAME=1
TI_FRAME_SPACING=1
VP_OUTPUT="VP.dat"
EOS_PLOT="VP_plot.png"
VOLS_OUTPUT="vols-bulks.tmp"

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================
check_step_complete() {
    [[ -f "$2" ]] && { echo "✓ $1 already complete - skipping"; return 0; }
    return 1
}

export_coexistence_data() {
    local TEMP=$(calc_temperature OSZICAR | awk '{print $2}')
    local PRESS=$(calc_pressure OUTCAR 2>&1 | grep -o '[0-9]*\.[0-9]*')
    local VOL=$(calc_volume OUTCAR)
    local vol_per_atom=$(echo "scale=6; $VOL / $COEX_ATOMS" | bc -l)
    
    cat > ../coex_results.dat << EOF
COEX_TEMP=$TEMP
COEX_PRESS=$PRESS
COEX_VOL=$vol_per_atom
EOF
    
    echo "✅ Coexistence: V=${VOL}Å³(${vol_per_atom}Å³/atom), P=${PRESS}GPa, T=${TEMP}K"
}


#===============================================================================
# PIPELINE EXECUTION
#===============================================================================
LOG_FILE="History_$(date +%Y%m%d_%H%M%S).log"
exec > "$LOG_FILE" 2>&1
echo "Pipeline started: $(date) | Element: $ELEMENT"

#===============================================================================
# COEXISTENCE PHASE
#===============================================================================
if ! check_step_complete "Coexistence search" "coex_results.dat"; then
    mkdir -p Coexistence && cd Coexistence
    cp ../POSCAR.coex POSCAR.coex               # make volume as a a global variable,  in POSCAR  #  remember voluem can be done with; sed -i "2s/.*/-$vol_s/" POSCAR
    sed -i "2s/.*/-$VOLUME_COEX/" POSCAR.coex
    TOTAL_ATOMS=$COEX_ATOMS therm_steps=$THERM_STEPS nve_steps=$NVE_STEPS
    
    main_exe || { echo "❌ Coexistence failed"; exit 1; }
    export_coexistence_data
    cd ..
fi

#===============================================================================
# TI PHASE
#===============================================================================
source coex_results.dat || { echo "❌ coex_results.dat not found"; exit 1; }
mkdir -p Free_energy && cd Free_energy
cp ../POSCAR.s . 2>/dev/null || true

echo "🔬 TI Pipeline: $TI_ATOMS $ELEMENT atoms | T=${COEX_TEMP}K"

# TI Steps
if ! check_step_complete "VP scan" "$VP_OUTPUT"; then
    calc_vp_scan "$COEX_VOL" "$TI_ATOMS" "$VP_NUM_POINTS" "$VP_OUTPUT" "$COEX_TEMP" "$TEMP_MELT" "$TI_THERM_STEPS_VP" "$ELEMENT" || { echo "❌ VP failed"; exit 1; }
fi

if ! check_step_complete "EOS fitting" "$EOS_PLOT"; then
    fit_eos_coex "3rd_Birch" "$VP_OUTPUT" "$COEX_PRESS" "$EOS_PLOT" "$VOLS_OUTPUT" "$ELEMENT" || { echo "❌ EOS failed"; exit 1; }
fi

if ! check_step_complete "MD sampling" "XDATCAR.s"; then
    sample_md_coex  "$COEX_TEMP" "$COEX_PRESS" "$TI_THERM_STEPS" "$ELEMENT" || { echo "❌ MD failed"; exit 1; }
fi

if ! check_step_complete "EAM TI" "s${TI_ATOMS}EAM/OUTCAR.${TI_START_FRAME}"; then
    sample_ti_configs "EAM" "$TI_ATOMS" "$ELEMENT" "$TI_START_FRAME" "$TI_FRAME_SPACING" "$COEX_TEMP" || { echo "❌ EAM failed"; exit 1; }
fi

if ! check_step_complete "DFT TI" "s${TI_ATOMS}DFT/OUTCAR.${TI_START_FRAME}"; then
    sample_ti_configs "DFT" "$TI_ATOMS" "$ELEMENT" "$TI_START_FRAME" "$TI_FRAME_SPACING" "$COEX_TEMP" "$KPOINTS" || { echo "❌ DFT failed"; exit 1; }
fi

cd ..

echo "✅ PIPELINE COMPLETE | Log: $LOG_FILE | $(date)"

