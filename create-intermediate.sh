#!/bin/bash

if [ -z $1 ]; then
    echo "first argument is the directory of your ca"
    exit 1
fi
base_dir=$1

root_dir=${base_dir}/root
root_key_path=${root_dir}/root.key.pem
root_crt_path=${root_dir}/root.crt.pem

intermediate_dir=${base_dir}/intermediate
intermediate_key_path=${intermediate_dir}/intermediate.key.pem
intermediate_csr_path=${intermediate_dir}/intermediate.csr.pem
intermediate_cert_path=${intermediate_dir}/intermediate.crt.pem

mkdir -p $intermediate_dir



# generate intermediate key 
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out ${intermediate_key_path}

# generate a signing request with the intermediate ca key
# Do note the pathlen basic constraint. It restricts the CA to only issue leaf certificates and no CA certificates: https://www.rfc-editor.org/rfc/rfc5280#section-4.2.1.9
# Also take a look at the nameConstraints extension. This extension limits the domain for leaf certificates. (https://www.rfc-editor.org/rfc/rfc5280#section-4.2.1.10)
# In this case, the intermediate CA certificate can only issue certificates for the domain "proxy.myhospital.com" 
openssl req -new -key ${intermediate_key_path} \
    -out ${intermediate_csr_path} \
    -subj '/CN=my-company-ca-intermediate' \
    -addext 'basicConstraints=critical,CA:true,pathlen:1' \
    -addext 'keyUsage=digitalSignature,keyCertSign' \
    -addext 'nameConstraints=critical,permitted;DNS:proxy.myhospital.com'


# sign the request with the root certificates key
openssl x509 -CA ${root_crt_path} -CAkey ${root_key_path} -days 8000 -req -in ${intermediate_csr_path} -out ${intermediate_cert_path} -copy_extensions copyall -set_serial 456