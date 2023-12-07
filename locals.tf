locals {
  # Create order
  function_name_create_order = "create-order"
  src_path_create_order      = "${path.module}/lambda/${local.function_name_create_order}"

  binary_name_create_order  = local.function_name_create_order
  binary_path_create_order  = "${path.module}/bin/${local.binary_name_create_order}"
  archive_path_create_order = "${path.module}/bin/${local.function_name_create_order}.zip"

  # Process order
  function_name_process_order = "process-order"
  src_path_process_order      = "${path.module}/lambda/${local.function_name_process_order}"

  binary_name_process_order  = local.function_name_process_order
  binary_path_process_order  = "${path.module}/bin/${local.binary_name_process_order}"
  archive_path_process_order = "${path.module}/bin/${local.function_name_process_order}.zip"
}
