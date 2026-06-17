#!/usr/bin/env bash
exec docker exec -i iic-osic-tools_xvnc_uid_1000 \
  bash -lc "export PDK=ihp-sg13g2; cd /foss/designs/SG13G2_ASIC-Design-FLL && $*"
