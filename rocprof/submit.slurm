#!/bin/bash
#SBATCH --partition=eap         # Partition (queue) name
#SBATCH --nodes=1                    # Total number of nodes
#SBATCH -J profile
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:50:00
#SBATCH --error=stdout
#SBATCH --gres=gpu:1

echo "Starting job $SLURM_JOB_ID at `date`"

ulimit -c unlimited
ulimit -s unlimited

echo "Running in partition  $SBATCH_PARTITION , $SLURM_PARTITION"
echo "SLURM_NTASKS_PER_NODE: $SLURM_NTASKS_PER_NODE"
echo "SLURM_NTASKS: $SLURM_NTASKS"

export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=1
export OMP_PROC_BIND=close
export OMP_PLACES=threads
source env_gpu.sh

export ESPRESSO_PSEUDO=../../test-suite/lastcomm/pseudo/
export CRAY_ACC_DEBUG=3

srun -N ${SLURM_NNODES} -n 1 rocprof --hip-trace --roctx-trace -i input.txt ./pw.x -i scf.in

echo "... finished job $SLURM_JOB_ID at `date`"
