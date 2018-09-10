#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

safe_source $_sdir/../config.sh

### Calculix and CGX
#-------------------------
cd
git clone https://github.com/luvres/calculix.git || { cd calculix && git pull && cd ..; }
cd calculix/ \
        && ccx_VERSION=`cat ./install | grep "export PROGSDIR=" | sed 's/^.*CalculiX-//'` \
	&& ./install

cp $HOME/CalculiX-${ccx_VERSION}/bin/ccx_${ccx_VERSION} /usr/bin/ccx \
	&& cp $HOME/CalculiX-${ccx_VERSION}/bin/cgx /usr/bin/cgx \


