project_id                = "aliz-diybi-ia"
region                    = "europe-west1"
zone                      = "europe-west1-b"
env                       = "dev"
vpc_ip_range              = "10.100.1.0/24"
instance_type             = "n1-standard-1"
gpu_type                  = "NVIDIA_TESLA_T4"
gpu_count                 = 1
pattern_stop              = "0 18 * * *"
pattern_start             = "0 8 * * *"
label_key                 = "instance-scheduler"
label_value               = "enabled"
scheduler_function_bucket = "auto_disable_enable_vm"
timezone                  = "CET"
