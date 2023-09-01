source libs/details.sh

function _start () {
	_title "INICIANDO O CLUSTER"
	sleep 1
	read -p "Digite o IP Address que a API serve vai está escutando: " IP_ADDRESS
	_line_long
	echo -e "${COR_CIANO}Criando o Cluster...${192.168.0.0/16}"
	_line_long
	sudo kubeadm init --apiserver-advertise-address $IP_ADDRESS --pod-network-cidr 192.168.0.0/16
	_line_long
	sleep 1

	echo -e "${COR_CIANO}Configurando o cluster para interagir por meio do Kubelet${COR_RESET}"
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
	sudo kubectl cluster-info
	_line_long
	sleep 1

	sudo kubectl get nodes
	_line_long
	sleep 1
}

function _calico () {
	_title "INICIALIZANDO A CNI DO CALICO"
	sleep 1
	sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
	_line_long
	sleep 1
}

function _flannel () {
	_title "INICIALIZANDO A CNI DO FLANNEL"
	sleep 1
	_line_long
	kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
	_line_long
	sleep 1
}

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
		_line_long
		_flannel
	elif [ "$cni" == "2" ]; then
		echo -e "${COR_CIANO}Calico...${COR_RESET}"
		_line_long
		_calico
	else
		echo "Opção inválida. Escolha 1 para Flannel ou 2 para Calico."
	fi
}

function _generate_token () {
	_title "GERAR TOKEN DE CONEXÃO COM O CLUSTER"
	sleep 1
	_line_long
	echo "Token:" && sudo kubeadm token create --print-join-command
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
		echo -e "${COR_VERMELHO}Nome do nó não pode estar em branco!${COR_RESET}"
		kubectl get nodes
	fi

	_line_long
	echo -e "${COR_CIANO}Drenando o nó!${COR_RESET}"
	kubectl drain "$NODE_NAME" --ignore-daemonsets --delete-local-data
	sleep 1

	_line_long
	echo -e "${COR_CIANO}Marcarndo o nó como não pronto!${COR_RESET}"
	kubectl cordon "$NODE_NAME"
	sleep 1

	_line_long
	echo -e "${COR_CIANO}REmovendo o nó do cluster!${COR_RESET}"
	kubectl delete node "$NODE_NAME"
	sleep 1

	_line_long
	echo -e "${COR_AMARELO}Nó $NODE_NAME foi removido do cluster!${COR_RESET}"
	sleep 1
	kubectl get nodes
}

function _alias () {
	_title "ALIAS 'KUBE' PARA CHAMAR O SCRIPT"

	if [ -f ~/.bashrc ]; then
		if grep -q "alias kube='cd /local_data && ./install_kubenetes.sh'" ~/.bashrc; then
			echo -e "${COR_VERMELHO}A linha já existe no arquivo ~/.bashrc.${COR_RESET}"
			_help
		else
			echo "alias kube='cd /local_data && ./install_kubenetes.sh'" >> ~/.bashrc
			echo -e "${COR_VERDE}Linha adicionada com sucesso ao ~/.bashrc!${COR_RESET} \ "
			echo -e "${COR_VERMELHO}Rode o comando <source ~/.bashrc no seu terminal!>${COR_RESET}"
		fi
	else
		echo -e "${COR_VERMELHO}O arquivo ~/.bashrc não foi encontrado. Certifique-se de que ele exista.${COR_RESET}"
		exit 1
	fi

	sleep 1
	source ~/.bashrc
}

function _help () {
	_title "MENU DE AJUDA"
	sleep 1
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
  -c | --calico            Habilitar a comunição entre os pods no cluster.
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
