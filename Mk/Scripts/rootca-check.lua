post-install-lua: [{
    args: ""
    code: <<EOS
crt = pkg.prefixed_path("share/certs/ca-root-nss.crt")
st = pkg.stat(crt)
if st == nil then
  pkg.print_msg(
     "The Network Security Services (NSS) root certificate is not installed.\n" ..
     "This package looks for that certificate so secure protocols may not be\n" ..
     "supported if alternate certificates cannot be located.\n" ..
     "\n" ..
     "To install this recommended certificate:\n" ..
     "   > rvn install -y nss~caroot~std\n\n")
end
EOS
}]
