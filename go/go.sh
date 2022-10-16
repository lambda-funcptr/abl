export GOPATH=$(readlink -f $(dirname $0))

cd "$GOPATH/funcptr.org/abl/bootmenu"

exec go ${@}