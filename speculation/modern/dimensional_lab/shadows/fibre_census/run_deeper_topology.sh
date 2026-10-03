#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../../../../.." && pwd)
cd "$ROOT"
python3 speculation/modern/dimensional_lab/shadows/fibre_census/20_support_configuration_homology.py
python3 speculation/modern/dimensional_lab/shadows/fibre_census/22_executable_product_tori.py
python3 speculation/modern/dimensional_lab/shadows/fibre_census/23_coefficient_field_pressure.py
python3 speculation/modern/dimensional_lab/shadows/fibre_census/24_causal_depth_persistence.py
