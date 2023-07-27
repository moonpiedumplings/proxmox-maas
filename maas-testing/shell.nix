{ pkgs ? import <nixpkgs> {} } :

pkgs.mkShell {
    packages = with pkgs; [ docker-compose ];
    # does not provide docker
}