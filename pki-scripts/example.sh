#!/bin/bash
set -e
./clean.sh
./gen_root_ca.sh capass changeit
./gen_node_cert.sh node-0 changeit capass 
./gen_client_node_cert.sh wdh-admin changeit capass
