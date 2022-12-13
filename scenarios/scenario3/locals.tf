locals {
  env = terraform.workspace
  project = basename(path.cwd)
}