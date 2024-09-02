

#Changes command for Grub 

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"/g' /etc/default/grub

update-grub


# Adds additionnal modules.
sed -i '/vfio.*/d' /etc/modules

echo "vfio">>/etc/modules
echo "vfio_iommu_type1">>/etc/modules
echo "vfio_pci">>/etc/modules
echo "vfio_virqfd">>/etc/modules



# No idea
sed -i '/options vfio_iommu_type1 allow_unsafe_interrupts=1/d' /etc/modprobe.d/iommu_unsafe_interrupts.conf
sed -i '/options kvm ignore_msrs=1/d' /etc/modprobe.d/kvm.conf


echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf


#Adds the usuall GPU drivers to the blacklist in order to prevent proxmox from using the GPU for the console. If you have an integrated card, you should be able to plug a monitor in order to access the console.

sed -i '/blacklist radeon/d' /etc/modprobe.d/blacklist.conf
sed -i '/blacklist nouveau/d' /etc/modprobe.d/blacklist.conf
sed -i '/blacklist nvidia/d' /etc/modprobe.d/blacklist.conf


echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf



# GPU passthrough
# This section will ask the user which graphic device should be passed through.

results=($(lspci -v | grep VGA | sed 's/ /_/g'))

#results=($(lspci -v | grep VGA | grep -o '[0-9][0-9]:[0-9][0-9].[0-9]'))

select choice in "${results[@]}"; do
	if [ "$choice" ]; then
		echo "You selected : $choice"
		result=$(echo $choice | grep -o '[0-9][0-9]:[0-9][0-9].')
		break
	else
		echo "invalid"
	fi
done


ids=($(lspci -v | grep -o $result[0-9] | sed 's/ /_/g' ))

concatID=""

for id in "${ids[@]}"; do
## Concat the results of the line bellow into the format []:[],[]:[] which can in used in the next command.
	res=$(lspci -n -s $id | grep -o [0-9,a-z][0-9,a-z][0-9,a-z][0-9,a-z]:[0-9,a-z][0-9,a-z][0-9,a-z][0-9,a-z])
	concatID+=$res","
done
concatID=${concatID: : -1}
echo $concatID

sed -i '/options vfio-pci ids=.* disable_vga=.*/d' /etc/modprobe.d/vfio.conf

echo "options vfio-pci ids=$concatID disable_vga=1"> /etc/modprobe.d/vfio.conf


# Updates the changes, computer should now restart and the selected GPU will no longer be available to proxmox. 
echo "Updates made, computer will now restart" 
update-initramfs -u
reset

reboot





