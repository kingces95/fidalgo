nix::chroot() {
    sudo apt-get update
    sudo apt-get install dchroot
    sudo apt-get install debootstrap
}

nix::chroot::test() {
    sudo mkdir /test
    sudo debootstrap \
        --variant=buildd \
        --arch amd64 \
        saucy \
        /test/ \
        http://mirror.cc.columbia.edu/pub/linux/ubuntu/archive/
}