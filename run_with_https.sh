#!/bin/bash

thin start --ssl --ssl-key-file ./localhost.key --ssl-cert-file ./localhost.crt

# rails s -b 'ssl://localhost:3000?key=./localhost.key&cert=./localhost.crt'
