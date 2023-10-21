#!/bin/bash

export PGSERVICE=graubrot

psql -f 10_functions.sql
psql -f 11_structure.sql
psql -f 12_generalization_25k.sql