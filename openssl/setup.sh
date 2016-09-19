##################Create the root pair#########################
mkdir /root/ca
cd /root/ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Create the root key
cd /root/ca
openssl genrsa -aes256 -out private/ca.key.pem 4096
#Enter pass phrase for ca.key.pem: secretpassword
#Verifying - Enter pass phrase for ca.key.pem: secretpassword

chmod 400 private/ca.key.pem

# Create the root certificate
cd /root/ca
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem

# Verify the root certificate
openssl x509 -noout -text -in certs/ca.cert.pem



##################Create the intermediate pair#########################
# intermediate certificate authority
mkdir /root/ca/intermediate
cd /root/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > /root/ca/intermediate/crlnumber

# Create the intermediate key
cd /root/ca
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096
#Enter pass phrase for intermediate.key.pem: secretpassword
#Verifying - Enter pass phrase for intermediate.key.pem: secretpassword
chmod 400 intermediate/private/intermediate.key.pem

# Create the intermediate certificate
cd /root/ca
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem

cd /root/ca
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem

# Verify the intermediate certificate
openssl x509 -noout -text \
      -in intermediate/certs/intermediate.cert.pem

openssl verify -CAfile certs/ca.cert.pem \
      intermediate/certs/intermediate.cert.pem

# Create the certificate chain file
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem


##################Sign server and client certificates#########################
# Create a key
cd /root/ca

# Although 4096 bits is slightly more secure than 2048 bits, it slows down TLS handshakes and significantly increases processor load during handshakes. For this reason, most websites use 2048-bit pairs.
openssl genrsa -aes256 \
      -out intermediate/private/www.example.com.key.pem 2048
chmod 400 intermediate/private/www.example.com.key.pem

# Create a certificate
cd /root/ca
openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/www.example.com.key.pem \
      -new -sha256 -out intermediate/csr/www.example.com.csr.pem
openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in intermediate/csr/www.example.com.csr.pem \
      -out intermediate/certs/www.example.com.cert.pem
chmod 444 intermediate/certs/www.example.com.cert.pem

# Verify the certificate
openssl x509 -noout -text \
      -in intermediate/certs/www.example.com.cert.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/www.example.com.cert.pem

# Deploy the certificate


##################Certificate revocation lists#########################
# Prepare the configuration file
# Create the CRL
cd /root/ca
openssl ca -config intermediate/openssl.cnf \
      -gencrl -out intermediate/crl/intermediate.crl.pem
# check the contents of the CRL
openssl crl -in intermediate/crl/intermediate.crl.pem -noout -text

# Revoke a certificate
openssl ca -config intermediate/openssl.cnf \
      -revoke intermediate/certs/bob@example.com.cert.pem



###########################Create Code Signing certificate##################
cd /home/oracle/Tina/openssl/openssl/ca
openssl genrsa -out intermediate/private/signer.code.sas.key.pem 2048
chmod 400 intermediate/private/signer.code.sas.key.pem
openssl req -config intermediate/openssl.cnf -key intermediate/private/signer.code.sas.key.pem \
	-new \
	-out intermediate/csr/signer.code.sas.csr.pem
openssl ca -config intermediate/openssl.cnf -days 375 -key bnt23as \
	-extensions signing_cert \
	-in intermediate/csr/signer.code.sas.csr.pem \
	-out intermediate/certs/signer.code.sas.cer.pem
chmod 400 intermediate/certs/signer.code.sas.cer.pem
openssl x509 -noout -text \
      -in intermediate/certs/signer.code.sas.cer.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/signer.code.sas.cer.pem

# usage http://www.herongyang.com/crypto/openssl_verify_2.html
openssl verify -CAfile certs/ca.cert.pem -untrusted intermediate/certs/ca-chain.cert.pem intermediate/certs/signer.code.sas.cer.pem

# export certificate chain
openssl pkcs12 -export -chain -in intermediate/certs/signer.code.sas.cer.pem \
	-inkey intermediate/private/signer.code.sas.key.pem \
	-CAfile intermediate/certs/ca-chain.cert.pem \
	-out intermediate/signer.code.sas.p12 -name codesinger

keytool -importkeystore -srckeystore signer.code.sas.p12 -srcstoretype pkcs12 -srcstorepass Test123! -destkeystore keystore.jks -deststorepass Test123!
keytool -list -keystore keystore.jks -storepass Test123! -v
keytool -printcert -jarfile sas-web/target/sas-web-1.1.3-SNAPSHOT.jar
jarsigner -keystore etc/security/truststore.jks -strict -verify sas-web/target/sas-web-1.1.3-SNAPSHOT.jar oracle
jarsigner -keystore etc/security/truststore.jks -strict -verify sas-service-rest/target/sas-service-rest-1.1.3-SNAPSHOT.jar oracle

keytool -list -keystore sas.truststore


[ signer_cert ]
# Extensions for client certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection


Country Name (2 letter code) [GB]:CN
State or Province Name [England]:SC
Locality Name []:CD
Organization Name [Alice Ltd]:EC Wise
Organizational Unit Name []:SAS
Common Name []:Code Signer
Email Address []:codesigner@ecwise.com


###########################Encode and Sign##################
openssl rsautl -encrypt -inkey test_pub.pem -pubin -in hello.txt -out hello.en
openssl rsautl -decrypt -inkey test.key.pem -in hello.en -out hello.de

openssl rsautl -encrypt -inkey mysql.pem -pubin -in mysql.txt | openssl base64
openssl rsautl -encrypt -inkey oracle.pem -pubin -in oracle.txt | openssl base64

# encrypt password and use base64 to store it.
--oracle prod
openssl rsautl -encrypt -inkey oracle.pem -pubin -in oracle.txt | openssl base64 > oracle.base64
cat oracle.base64
base64 -d  oracle.base64 > oracle.en & openssl rsautl -decrypt -inkey oracle.key.pem -in oracle.en -out oracle.de
cat oracle.de

--mysql prod
openssl rsautl -encrypt -inkey mysql.pem -pubin -in mysql.txt | openssl base64 > mysql.base64
cat mysql.base64
base64 -d  mysql.base64 > mysql.en & openssl rsautl -decrypt -inkey mysql.key.pem -in mysql.en -out mysql.de
cat mysql.de




