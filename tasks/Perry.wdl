version 1.0

# task GatherVcfs {

# input {
# Array[File] input_vcfs
# String output_vcf_name
# Int disk_size
# String gatk_docker = "gcr.io/arcus-jpe-pipe-stage-4f4279cc/gatk:4.1.1.0"
# }

# parameter_meta {
# input_vcfs: {
# localization_optional: true
# }
# }

# command <<<
# set -euo pipefail

# # --ignore-safety-checks makes a big performance difference so we include it in our invocation.
# # This argument disables expensive checks that the file headers contain the same set of
# # genotyped samples and that files are in order by position of first record.
# gatk --java-options -Xms6g \
# GatherVcfsCloud \
# --ignore-safety-checks \
# --gather-type BLOCK \
# --input ~{sep=" --input " input_vcfs} \
# --output ~{output_vcf_name}

# tabix ~{output_vcf_name}
# >>>

# runtime {
# noAddress: true
# memory: "7 GiB"
# cpu: "1"
# disks: "local-disk " + disk_size + " HDD"
# preemptible: 0
# docker: gatk_docker
# }

# output {
# File output_vcf = "~{output_vcf_name}"
# File output_vcf_index = "~{output_vcf_name}.tbi"
# }
# }

task DecomposeNormalizeVCF {
  input {
    File input_file
    File ? input_idx_file

    File reference
    File reference_idx

    Float memory = 4
    Int cpu = 1
    Int disk_size

    String output_filename = basename(input_file) + ".decomposed.normalized.vcf"
  }

  command {
    set -Eeuxo pipefail;

     /vt/vt decompose \
      -s ~{input_file} | \
     /vt/vt normalize - \
      -r ~{reference} \
      -o ~{output_filename};
  }

  output {
    File vcf_file = "~{output_filename}"
  }

  runtime {
    noAddress: true
    memory: memory + " GB"
    cpu: cpu
    disks: "local-disk " + disk_size + " HDD"
    docker: "gcr.io/arcus-jpe-pipe-stage-4f4279cc/vt:vJan06_2020" 
  }

  parameter_meta {
    input_file: "VCF file."
    input_idx_file: "VCF file index (.tbi)."
    reference: "Reference fasta sequence."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    vt_version: "v0.5772-60f436c3"
    version: "0.1.0"
  }
}

task FinalSelectVar {
  input {
    File input_file
    Float memory = 4
    Int cpu = 1
    Int disk_size

    String output_vcf = basename(input_file) + ".vars.vcf"
    String output_cas = basename(input_file) + ".vars.vcf.cas"
  }
  command {
    set -Eeuxo pipefail;
    gatk --java-options -Xmx5g -Xms5g \
    SelectVariants -V ~{input_file} \
    --exclude-non-variants \
    --output ~{output_vcf}; \
    /bin/cp-lfs -cas.addr https://cas.arcus.chop.edu -cas.upload -cas.tls.verify=false ~{output_vcf} ~{output_cas}

  }

  output {
    File vcf_file = "~{output_vcf}"
    File cas_file = "~{output_cas}"
  }

  runtime {
    noAddress: true
    memory: memory + " GB"
    cpu: cpu
    disks: "local-disk " + disk_size + " HDD"
    docker: "gcr.io/arcus-jpe-pipe-stage-4f4279cc/gatk-cas:snap1" 
  }


}