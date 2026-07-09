#!/bin/bash
# Membrane workflow: runs the 6-stage CHARMM-GUI membrane equilibration
# (step6.0 minimization + step6.1-6.6 restrained equilibration) followed by a
# short MD for CV width. The step6.* .mdp files are produced by CHARMM-GUI's
# Membrane Builder and are NOT included here - only step7_for_CV_width.mdp is.
# Expects: step5_input.gro, topol.top, index.ndx (and the step6.* mdp files).
#
# Cluster-specific: adjust or remove the module load line for your environment,
# and replace gmx_mpi with `gmx` for a non-MPI GROMACS build.
#source /etc/modules.sh
module load gromacs2023-5_gnu_mpi_gpu
# Minimization
gmx_mpi grompp -f step6.0_minimization.mdp -o step6.0_minimization.tpr -c step5_input.gro -r step5_input.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.0_minimization

# Equilibration 
gmx_mpi grompp -f step6.1_equilibration.mdp -o step6.1_equilibration.tpr -c step6.0_minimization.gro -r step6.0_minimization.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.1_equilibration

gmx_mpi grompp -f step6.2_equilibration.mdp -o step6.2_equilibration.tpr -c step6.1_equilibration.gro -r step6.1_equilibration.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.2_equilibration

gmx_mpi grompp -f step6.3_equilibration.mdp -o step6.3_equilibration.tpr -c step6.2_equilibration.gro -r step6.2_equilibration.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.3_equilibration

gmx_mpi grompp -f step6.4_equilibration.mdp -o step6.4_equilibration.tpr -c step6.3_equilibration.gro -r step6.3_equilibration.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.4_equilibration

gmx_mpi grompp -f step6.5_equilibration.mdp -o step6.5_equilibration.tpr -c step6.4_equilibration.gro -r step6.4_equilibration.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.5_equilibration

gmx_mpi grompp -f step6.6_equilibration.mdp -o step6.6_equilibration.tpr -c step6.5_equilibration.gro -r step6.5_equilibration.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step6.6_equilibration



# MD run (1 ns) for CV width calculation
gmx_mpi grompp -f step7_for_CV_width.mdp -o step7_for_CV_width.tpr -c step6.6_equilibration.gro -r step6.6_equilibration.gro -p topol.top -n index.ndx 
gmx_mpi mdrun -v -deffnm step7_for_CV_width

# -maxwarn 1