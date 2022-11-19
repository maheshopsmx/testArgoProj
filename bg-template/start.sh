#!/bin/bash
mkdir -p opsmx
cd opsmx
curl https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-template/create.sh -o create.sh
curl https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-template/rollout.yaml -o rollout.yaml
curl https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-template/service.yaml -o service.yaml
curl https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-template/services.txt -o services.txt
curl https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-template/template.yaml -o template.yaml
curl https://raw.githubusercontent.com/gopaljayanthi/testArgoProj/main/bg-template/trigger-analysis.sh -o trigger-analysis.sh
