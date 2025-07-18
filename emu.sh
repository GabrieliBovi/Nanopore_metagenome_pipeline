#!/bin/bash

echo "Diretorio"
#mkdir emu
cd emu

# ========================
# 1. Download do banco SILVA para Emu
# ========================
echo ">>> Baixando banco SILVA (Emu)..."
#pip install osfclient
export EMU_DATABASE_DIR=./emu_db
mkdir -p ${EMU_DATABASE_DIR}
cd ${EMU_DATABASE_DIR}
osf -p 56uf7 fetch osfstorage/emu-prebuilt/emu.tar
tar -xvf emu.tar
cd ..
cd ..

# ========================
# 1. Instalação do ambiente
# ========================
echo ">>> Criando ambiente Conda e instalando Emu..."
#conda create -y -n emu_env python=3.7
#conda activate emu_env
#mamba install -c bioconda -c conda-forge emu

# Ative o ambiente
source ~/anaconda3/etc/profile.d/conda.sh
conda activate emu_env
echo "Conda activate"

# ========================
# 3. Análise com Emu (2 amostras)
# ========================
# Lista de amostras
declare -a SAMPLES=("filt_reads/filtlong/RS_fil.fastq.gz" "filt_reads/filtlong/RSuper_fil.fastq.gz" "filt_reads/filtlong/TS_fil.fastq.gz" "filt_reads/filtlong/TSuper_fil.fastq.gz")

for SAMPLE in "${SAMPLES[@]}"
do
  NAME=$(basename "$SAMPLE" _fil.fastq.gz)
  echo ">>> Rodando Emu para $NAME..."

  emu abundance $SAMPLE \
    --db emu/emu_db \
    --threads 7 \
    --output-dir emu \
    --keep-counts \
    --keep-read-assignments \
    --N 50
done

# ========================
# 4. Combinar os resultados das amostras
# ========================

echo ">>> Combinando resultados..."
#emu combine-outputs emu species
emu combine-outputs emu/ tax_id

echo ">>> Pipeline finalizado com sucesso!"
echo "Arquivo combinado: emu_results/emu-combined-tax_id.tsv"

conda deactivate
# Ref: https://github.com/treangenlab/emu 
