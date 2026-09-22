#!/bin/bash
# Soluble-protein workflow: minimization -> equilibration -> short MD for CV width.
# Expects CHARMM-GUI-style inputs in the working directory:
#   step3_input.gro, topol.top
# newindex.ndx is generated below from step3_input.gro.
#
# Cluster-specific: adjust or remove the module load line for your environment,
# and replace gmx_mpi with `gmx` for a non-MPI GROMACS build.
module load gromacs2023-4_gnu_mpi_gpu

# Index file with the default groups (Protein, Non-Protein, ...) used by tc_grps/comm_grps
echo q | gmx_mpi make_ndx -f step3_input.gro -o newindex.ndx
# q --> save and quit

# Protein-only PDB of the starting structure (optional, e.g. as PLUMED reference)
echo 1 | gmx_mpi editconf -f step3_input.gro -o apo_processed_step3.pdb -n newindex.ndx
# 1 --> (Protein)

# Minimization
gmx_mpi grompp -f step4.0_minimization.mdp -o step4.0_minimization.tpr -c step3_input.gro -r step3_input.gro -p topol.top -n newindex.ndx -maxwarn 1
gmx_mpi mdrun -v -deffnm step4.0_minimization

# Equilibration (AMBER force field)
gmx_mpi grompp -f step4.1_equilibration_amberff.mdp -o step4.1_equilibration.tpr -c step4.0_minimization.gro -r step4.0_minimization.gro -p topol.top -n newindex.ndx -maxwarn 2
gmx_mpi mdrun -v -deffnm step4.1_equilibration

# Short MD to measure collective-variable fluctuations (CV width for metadynamics)
gmx_mpi grompp -f step5_for_CV_width.mdp -o step5_for_CV_width.tpr -c step4.1_equilibration.gro -r step4.1_equilibration.gro -p topol.top -n newindex.ndx -maxwarn 1
gmx_mpi mdrun -v -deffnm step5_for_CV_width

# Plain production MD instead of the CV-width run (uncomment to use):
# gmx_mpi grompp -f step5_production_amberff.mdp -o step5_production.tpr -c step4.1_equilibration.gro -r step4.1_equilibration.gro -p topol.top -n newindex.ndx -maxwarn 1
# gmx_mpi mdrun -v -deffnm step5_production
