#!/bin/bash

base_dir=$1

if [ -z $2 ]; then
    echo "first argument is the directory of your ca, second argument is the subject alternative name for your leaf certificate"
    exit 1
fi

root_dir=${base_dir}/root
root_crt_path=${root_dir}/root.crt.pem

intermediate_dir=${base_dir}/intermediate
intermediate_key_path=${intermediate_dir}/intermediate.key.pem
intermediate_crt_path=${intermediate_dir}/intermediate.crt.pem

leaf_dir=${base_dir}/leaf
leaf_key_path=${leaf_dir}/${2}.key.pem
leaf_csr_path=${leaf_dir}/${2}.csr.pem
leaf_crt_path=${leaf_dir}/${2}.crt.pem
leaf_chain_path=${leaf_dir}/${2}.chain.pem

mkdir -p $leaf_dir

openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out ${leaf_key_path}


# generate a signing request with the leaf key
openssl req -new -key ${leaf_key_path} \
    -out ${leaf_csr_path} \
    -subj "/CN=${2}" \
    -addext "subjectAltName=DNS:${2}" \
    -addext "extendedKeyUsage=serverAuth"


# sign the request with the intermediate certificates key
openssl x509 -CA ${intermediate_crt_path} -CAkey ${intermediate_key_path} -days 365 -req -in ${leaf_csr_path} -out ${leaf_crt_path} -copy_extensions copyall -set_serial $(date "+%s")

cat ${leaf_crt_path} ${intermediate_crt_path} ${root_crt_path} > ${leaf_chain_path}