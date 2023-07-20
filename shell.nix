{ pkgs ? import <nixpkgs> {} } :

pkgs.mkShell {
    packages = with pkgs; [ packer libnbd fuse2fs qemu];
    # Provides packer, and nbdfuse, required by scripts. 
    # does not provide qemu, qemu OVMF (example firmware), fusefat, or fuse2fs, also required.
    # does not provide nbdkit
}
