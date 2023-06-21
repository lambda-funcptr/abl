export GOPATH=$(readlink -f $(dirname $0))

cd "$GOPATH/funcptr.org/abl/bootmenu"

exec go build -v -a -ldflags "-w -s -extldflags -static" -o ../../../../dist/bootmenu cmd/bootmenu.go