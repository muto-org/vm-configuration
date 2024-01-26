#!/bin/bash

# Set up and run Microsoft Defender
# Note: Before uncommenting this line, ensure you have followed the instructions from the README.md in the /microsoft-defender-setup directory
#       to ensure your liecense is properly configured.

echo "Running defender script"

(cd ./microsoft-defender-setup && ./setup.sh) || exit 1

echo "Running sbom script"
# Run SBOM generation script
(cd ./sbom-generation && ./setup.sh) || exit 1