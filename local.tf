locals {

  prefix = "docker-%{if terraform.workspace != "default"}${terraform.workspace}-%{else}%{endif}"

}
