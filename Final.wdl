version 1.0

workflow Normalize {
  String pipeline_version = "1.2"
  input {
    Array[File] vcf_files
    String out_prefix
  }

  call Tasks.GatherVcfs as gather {
    input:
      vcf_files = vcf_files
  }

  call Tasks.Normalize as norm {
    input:
      vcf_file = gather.output_vcf
      out_prefix = out_prefix
  }

  output {
    File output_vcf = norm.output_vcf
    File output_idx = norm.output_idx
  }
}