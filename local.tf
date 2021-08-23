locals {

  prefix = "${var.prefix}-%{if terraform.workspace != "default"}${terraform.workspace}-%{else}%{endif}"

}
