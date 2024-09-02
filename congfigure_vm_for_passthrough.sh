
RED='\033[0;31m'
NC='\033[0m' # No Color
filePath="/etc/pve/qemu-server/"


echo "This operation will now change a few configurations on a VM to allow GPU passthrough."
echo "The VM must already be created before running this script and may not work otherwise."


printf "\n~~~~~~~~~~~~~\nHere are the current available Vms\n"
ls $filePath
printf "\n~~~~~~~~~~~~\n"

path=""
while :
do
	read -p 'VM id : ' id
	path="$filePath$id.conf"

	if [ -f "$path" ]; then
		break
	fi

	echo -e "${RED}A configuration fire for this if does not exist. Did you create the VM ?${NC}"
	printf "\n\n"
done

echo "you have selected $id. File located at $path has been modified."

echo "machine: q35">> $path
echo "cpu: host,hidden=1,flags=+pcid">> $path
echo "args: -cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'">> $path
echo "bios: ovmf">> $path



