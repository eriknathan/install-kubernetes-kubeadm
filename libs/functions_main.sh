source libs/details.sh

function _cni () {
	_title "ESCOLHENDO A CNI DO KUBERNETES"
	
	echo -e "${COR_CIANO}Escolha qual CNI você quer usar: ${COR_RESET}"
	echo -e "${COR_VERDE}1.${COR_RESET} Flannel"
	echo -e "${COR_VERDE}2.${COR_RESET} Calico"

	_line_long
	read -p "Opção: " cni	
	sleep 1

	if [ "$cni" == "1" ]; then
		echo -e "${COR_CIANO}Flannel...${COR_RESET}"
		NETWORK_CIDR="10.244.0.0/16"
		sleep 1
		_line_long
		kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
		_line_long

	elif [ "$cni" == "2" ]; then
		echo -e "${COR_CIANO}Calico...${COR_RESET}"
		NETWORK_CIDR="192.168.0.0/16"
		sleep 1
		_line_long
		sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
		_line_long
	else
		echo "Opção inválida. Escolha 1 para Flannel ou 2 para Calico."
	fi
}

function _start () {
	_title "INICIANDO O CLUSTER"

	echo -e "${COR_CIANO}Criando o Cluster via Kubeadm!${COR_RESET}"
		_line_long
		sleep 1
		echo -e "${COR_CIANO}Interfaces de rede do sistema:${COR_RESET}"
		ip -4 -o addr show | awk '{print $2 ":", $4}' | cut -d '/' -f 1
		_line_long
		read -p "Digite o IP Address que a API serve vai está escutando: " IP_ADDRESS
		_line_long

	echo -e "${COR_CIANO}Escolha qual CNI você quer usar!${COR_RESET}"
		_line_long
		echo -e "${COR_VERDE}1.${COR_RESET} Flannel"
		echo -e "${COR_VERDE}2.${COR_RESET} Calico"
		
		_line_long
		read -p "Opção: " cni	
		_line_long
		sleep 1

		if [ "$cni" == "1" ]; then
			echo -e "${COR_CIANO}Flannel...${COR_RESET}"
			NETWORK_CIDR="10.244.0.0/16"
			sleep 1
			_line_long
			kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
			_line_long
		elif [ "$cni" == "2" ]; then
			echo -e "${COR_CIANO}Calico...${COR_RESET}"
			NETWORK_CIDR="192.168.0.0/16"
			sleep 1
			_line_long
			sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
			_line_long
		else
			echo "Opção inválida. Escolha 1 para Flannel ou 2 para Calico."
		fi

	echo -e "${COR_CIANO}Criando o Cluster...${COR_RESET}"
		_line_long
		echo -e "${COR_AMARELO}IP: $IP_ADDRESS | NETWORK_CIDR: $NETWORK_CIDR${COR_RESET}"
		sudo kubeadm init --apiserver-advertise-address $IP_ADDRESS --pod-network-cidr $NETWORK_CIDR
		_line_long
		sleep 1

	echo -e "${COR_CIANO}Configurando o cluster para interagir por meio do Kubelet!${COR_RESET}"
		_line_long
		mkdir -p $HOME/.kube
		sleep 1

		sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
		sleep 1

		sudo chown $(id -u):$(id -g) $HOME/.kube/config
		sleep 1
}

function _info () {
	_title "INFORMAÇÕES DO CLUSTER"

	sleep 1
	echo -e "${COR_CIANO}Informações do Cluster!${COR_RESET}"
		_line_long
		sudo kubectl cluster-info
		_line_long
		sleep 1

	echo -e "${COR_CIANO}Listando Nodes do Cluster!${COR_RESET}"
		_line_long
		sudo kubectl get nodes
		_line_long
		sleep 1
}

function _generate_token () {
	_title "GERAR TOKEN DE CONEXÃO COM O CLUSTER"

	sleep 1
	_line_long
	echo "Token (rodar como sudo):" && sudo kubeadm token create --print-join-command
	_line_long
	sleep 1
}

function _disconect_worker () {
	_title "DESCONECTAR UM WORKER DE UM CLUSTER"

	sleep 1
	kubectl get nodes
	_line_long
	read -p "Digite o nome do nó a ser desconectado: " NODE_NAME
	_line_long
	sleep 1

	if [ -z "$NODE_NAME" ]; then
		echo -e "${COR_VERMELHO}Nome do node não pode estar em branco!${COR_RESET}"
		kubectl get nodes
		_line_long
	fi
	
	echo -e "${COR_CIANO}Drenando o nó!${COR_RESET}"
	_line_long
	kubectl drain "$NODE_NAME" --ignore-daemonsets --delete-local-data
	sleep 1
	_line_long

	echo -e "${COR_CIANO}Marcarndo o nó como não pronto!${COR_RESET}"
	_line_long
	kubectl cordon "$NODE_NAME"
	sleep 1

	_line_long
	echo -e "${COR_CIANO}REmovendo o nó do cluster!${COR_RESET}"
	_line_long
	kubectl delete node "$NODE_NAME"
	sleep 1

	_line_long
	echo -e "${COR_AMARELO}Nó $NODE_NAME foi removido do cluster!${COR_RESET}"
	_line_long
	sleep 1
	kubectl get nodes
}

function _alias () {
	_title "ALIAS 'KUBE' PARA CHAMAR O SCRIPT"

	_line_long
	read -p "Qual shell você está usando? (Digite 'bash' ou 'zsh'): " SHELL

	if [ "$SHELL" == "bash" ]; then
		SHELL_FILE="$HOME/.bashrc"
	elif [ "$SHELL" == "zsh" ]; then
		SHELL_FILE="$HOME/.zshrc"
	else
		echo -e "${COR_VERMELHO}Shell não suportado. Por favor, escolha 'bash' ou 'zsh'.${COR_RESET}"
		exit 1
	fi
	_line_long
	sleep 1
	
	echo $SHELL_FILE
	_line_long

	if [ -f $SHELL_FILE  ]; then
		if grep -q "alias kube='cd /local_data && ./install_kubenetes.sh'" $SHELL_FILE; then
			echo -e "${COR_VERMELHO}A linha já existe no arquivo $SHELL_FILE.${COR_RESET}"
			_line_long
			_help
		else
			echo "alias kube='cd /local_data && ./install_kubenetes.sh'" >> $SHELL_FILE
			echo -e "${COR_VERDE}Linha adicionada com sucesso ao $SHELL_FILE!${COR_RESET}"
			_line_long
			echo -e "${COR_VERMELHO}Rode o comando <source $SHELL_FILE> no seu terminal!${COR_RESET}"
		fi
	else
		echo -e "${COR_VERMELHO}O arquivo $SHELL_FILE não foi encontrado. Certifique-se de que ele existe.${COR_RESET}"
		exit 1
	fi
	sleep 1
}

function _help () {
	echo "
Usage: $ ./install_kubenetes.sh [parâmetros]

Parâmetros aceitos:
  -m | --menu              Menu de Inicialização.
  -d | --deps              Instalação das dependências.
  -s | --start             Iniciar Cluster Kubernetes.
  -i | --info              Obter informações do cluster.
  -t | --token             Token de conexão com workers.
  -w | --worker-down       Token de conexão com workers.
  -a | --alias             Chamar o script com 'kube' no terminal.
  -c | --cni               Escolher a CNI do Kubernetes.
  -h | --help              Menu de ajuda.
"
	sleep 1
}

function _error () {
	sleep 1
	echo -e "${COR_VERMELHO}O parâmetro $1 não existe.${COR_RESET}"
	_line_long
	sleep 1
	_help
	sleep 1
	exit 1
}
