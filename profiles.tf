// Create a CoreOS-install profile
resource "matchbox_profile" "container-linux-install" {
  name   = "container-linux-install"
  kernel = "/assets/coreos/${var.container_linux_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.container_linux_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
    "acpi=off",
    "clocksource=notsc",
    "coreos.autologin",
    "ipv6.disable=1",
  ]

  container_linux_config = "${data.template_file.container-linux-install-config.rendered}"
}

data "template_file" "container-linux-install-config" {
  template = "${file("${path.module}/cl/container-linux-install.yaml.tmpl")}"

  vars {
    container_linux_channel = "${var.container_linux_channel}"
    container_linux_version = "${var.container_linux_version}"
    ignition_endpoint       = "${format("%s/ignition", var.matchbox_http_endpoint)}"
    install_disk            = "${var.install_disk}"
    container_linux_oem     = "${var.container_linux_oem}"

    # only cached-container-linux profile adds -b baseurl
    baseurl_flag = ""
  }
}

// Install Network
resource "matchbox_profile" "core" {
  name                   = "core"
  container_linux_config = "${file("${path.module}/cl/core.yaml.tmpl")}"
}
