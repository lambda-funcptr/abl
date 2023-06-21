FROM alpine:edge
RUN apk add amd-ucode efi-mkuki gummiboot intel-ucode
ENTRYPOINT sh /config/mkuki.sh