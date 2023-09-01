source libs/details.sh

function _desable_swap () {
	_title "DESABILITANDO O SWAP"

	echo -e "${COR_CIANO}Desabilitando o swap${COR_RESET}"
		sudo swapoff -a && \
		_line_long
		sleep 1
		sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && \
		sleep 1

	echo -e "${COR_CIANO}Ajustando parêmetros${COR_RESET}"
		echo "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/containerd.conf && \
		_line_long
		sleep 1
		sudo modprobe br_netfilter && \
		sleep 1
		sudo modprobe overlay && \
		sleep 1

	echo -e "${COR_CIANO}Parâmetros para o kubernetes${COR_RESET}"
		echo "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/kubernetes.conf && \
		_line_long
		sleep 1

	echo -e "${COR_CIANO}Aplicando as mudanças (recarregando as configurações de kernel)${COR_RESET}"
		_line_long
		sudo sysctl --system
		_line_long
		sleep 1
}

function _install_containerd () {
	_title "INSTALANDO O CONTAINERD"

		echo -e "${COR_CIANO}Instalando as depedências!${COR_RESET}"
		_line_long
		sudo apt install -y curl gnupg software-properties-common apt-transport-https ca-certificates && \
		_line_long
		sleep 1

	echo -e "${COR_CIANO}Habilitando o repositório do Docker!${COR_RESET}"
		_line_long
		sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg && \
		sleep 1
		_line_long
		sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
		sleep 1
		_line_long

	echo -e "${COR_CIANO}Instalando o containerd!${COR_RESET}"
		_line_long
		sudo apt install containerd.io -y && \
		sleep 1
		_line_long

	echo -e "${COR_CIANO}Configurando o containerd para que inicie usando o systemd como cgroup!${COR_RESET}"
		sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1 && \
		_line_long
		sleep 1
		sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml && \
		_line_long
		sleep 1

	echo -e "${COR_CIANO}Reiniciando e habilitando o serviço do Containerd!${COR_RESET}"
		sudo systemctl restart containerd && \
		_line_long
		sleep 1
		sudo systemctl enable containerd
		_line_long
		sleep 1
}

function _add_kubernetes_repo () {
	_title "ADD REPOSITÓRIO DO KUBERNETES"
	echo -e "${COR_CIANO}Adicionando chave no sistema!${COR_RESET}"
		_line_long
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B53DC80D13EDEF05
		_line_long
		sleep 1
		sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg  sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg && \
		_line_long
		sleep 1
		sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" && \
		_line_long
		sleep 1
		
	echo -e "${COR_CIANO}Atualizando o sistema!${COR_RESET}"
		_line_long
		sudo apt update
		sleep 1
}

function _install_kubelet () {
	_title "INSTALANDO O KUBELET"

	echo -e "${COR_CIANO}Instalando o Kubelet!${COR_RESET}"
		_line_long
		sudo apt install -y kubelet && \
		_line_long
		sleep 1
		sudo apt-mark hold kubelet 
		_line_long
		sleep 1
}

function _install_kubeadm () {
	_title "INSTALANDO O KUBEADM"

	echo -e "${COR_CIANO}Instalando o Kubeadm!${COR_RESET}"
		_line_long
		sudo apt install -y kubeadm && \
		_line_long
		sleep 1
		sudo apt-mark hold kubeadm
		_line_long
		sleep 1
}

function _install_kubectl () {
	_title "INSTALANDO O KUBECTL"

	echo -e "${COR_CIANO}Instalando o Kubectl!${COR_RESET}"
		_line_long
		sudo apt install -y kubectl && \
		_line_long
		sleep 1
		sudo apt-mark hold kubectl
		_line_long
		sleep 1
}

function _install_deps () {
	sleep 1
	[ -z "`sudo swapon --show`" ] && _desable_swap
	sleep 1
	[ -z "`which containerd`" ]   && _install_containerd
	sleep 1
	_add_kubernetes_repo
	sleep 1
	[ -z "`which kubelet`" ]      && _install_kubelet
	sleep 1
	[ -z "`which kubeadm`" ]      && _install_kubeadm
	sleep 1
	[ -z "`which kubectl`" ]      && _install_kubectl
	sleep 1
}
