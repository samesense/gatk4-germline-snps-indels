version 1.0

import "tasks/Perry.wdl" as Tasks
#import "https://raw.githubusercontent.com/samesense/gatk4-germline-snps-indels/2.0.0/tasks/Perry.wdl" as Tasks

workflow Normalize {
  String pipeline_version = "1.2"
  input {
    File vcf_file
    File vcf_idx
    File reference
    File reference_idx
    Int large_disk
  }

  call Tasks.DecomposeNormalizeVCF as norm {
    input:
      input_file = vcf_file,
      input_idx_file = vcf_idx,
      reference = reference,
      reference_idx = reference_idx,
      disk_size = large_disk,
  }

call Tasks.FinalSelectVar as select {
    input:
      input_file = norm.vcf_file,
      disk_size = large_disk,
  }

  output {
    File output_vcf = select.vcf_file
    File output_vcf_cas = select.vcf_cas_file
    File output_idx = select.idx_file
    File output_idx_cas = select.idx_cas_file

  }
}