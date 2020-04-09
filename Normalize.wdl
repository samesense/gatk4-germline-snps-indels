version 1.0

import "https://raw.githubusercontent.com/samesense/gatk4-germline-snps-indels/2.0.0/tasks/Perry.wdl" as Tasks

workflow Normalize {
  String pipeline_version = "1.2"
  input {
    Array[File] vcf_files
    String output_vcf_name
    Int large_disk
  }

  call Perry.GatherVcfs as gather {
    input:
      input_vcfs = vcf_files,
      output_vcf_name = output_vcf_name + ".vcf.gz",
      disk_size = large_disk
  }

  # call Perry.Normalize as norm {
  #   input:
  #     vcf_file = gather.output_vcf,
  #     out_prefix = out_prefix
  # }

  output {
    File output_vcf = gather.output_vcf
    File output_idx = gather.output_vcf_idx
  }
}