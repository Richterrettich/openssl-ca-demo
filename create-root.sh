#!/bin/bash
if [ -z $1 ]; then
    echo "first argument is the directory of your ca"
    exit 1
fi

base_dir=$1

root_dir=${base_dir}/root
root_key_path=${root_dir}/root.key.pem
root_cert_path=${root_dir}/root.crt.pem
root_csr_path=${root_dir}/root.csr.pem
mkdir -p $root_dir

# generate root key 
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out ${root_key_path}

# generate a signing request with the root ca key
openssl req -new -key ${root_key_path} \
    -out ${root_csr_path} \
    -subj '/CN=my-company-ca-root' \
    -addext 'basicConstraints=critical,CA:true' \
    -addext 'keyUsage=digitalSignature,keyCertSign' 


# sign the self sign the request. This is a root certificate after all
openssl x509 -signkey ${root_key_path} -days 8000 -req -in ${root_csr_path} -out ${root_cert_path} -copy_extensions copyall -set_serial 123