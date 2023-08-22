openssl genrsa 2048 > host.key
openssl req -new -x509 -nodes -sha256 -days 365 -key host.key -out host.cert
openssl x509 -in host.cert -out cert.pem -outform PEM
cat host.cert host.key > key.pem

