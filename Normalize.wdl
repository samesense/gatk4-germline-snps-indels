version 1.0

import "https://raw.githubusercontent.com/samesense/gatk4-germline-snps-indels/2.0.0/tasks/Perry.wdl" as Tasks

workflow Normalize {
  String pipeline_version = "1.2"
  input {
    File vcf_file
    File vcf_idx
    File reference
    File reference_idx
    String output_vcf_name
    Int large_disk
  }

  # call Perry.GatherVcfs as gather {
  #   input:
  #     input_vcfs = vcf_files,
  #     output_vcf_name = output_vcf_name + ".vcf.gz",
  #     disk_size = large_disk
  # }

  call Tasks.DecomposeNormalizeVCF as norm {
    input:
      input_file = vcf_file,
      input_idx_file = vcf_idx,
      reference = reference,
      reference_idx = reference_idx,
      disk_size = large_disk,
      out_prefix = output_vcf_name
  }

  output {
    File output_vcf = norm.output_vcf
  }
}