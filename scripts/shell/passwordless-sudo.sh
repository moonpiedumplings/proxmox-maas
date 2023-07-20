#!/bin/sh
echo "test ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/99_sudo_include_file # TEMPLATE THIS USER
visudo -cf /etc/sudoers.d/99_sudo_include_file