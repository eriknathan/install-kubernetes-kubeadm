#!/usr/bin/env bash
#
# install_kubenetes.sh - Instalação do Kubernetes no Ubuntu 22.04 LTS
#
# Autor: Erik Nathan | GitHub: @eriknathan
# ------------------------------------------------------------------------- #
# Descrição:
#  --------------------------------------------------------------
#  Observações:
#    Para automatizar o script rode o comando <./install_kubenetes.sh -a ou --alias>
#	 e em seguida <source ~/.bashrc> no seu terminal.
#	 Agora você só precisa chamar o nome <kube> no terminal que ele já vai aparecer!
#  --------------------------------------------------------------
#  Comandos:
#  	 $ ./install_kubenetes.sh ou kube
#  	 $ ./install_kubenetes.sh --help ou kube --help
#  	 $ ./install_kubenetes.sh --menu ou kube --menu
#  	 $ ./install_kubenetes.sh -d -s -c ou kube -d -s -c (Instala tudo direto)
#  --------------------------------------------------------------
#  Arquivios:
# 	 ├── libs
# 	 │   ├── details.sh - Detalhes (cores e títulos)
# 	 │   ├── functions_deps.sh - funções de dependências
# 	 │   └── functions_main.sh - funções principais
#    ├── install_kubenetes.sh - script principal
# 	 └── Vagrantfile - Script para subir 3 VMs no Virutal Box, sendo uma Master e duas Workers
#  --------------------------------------------------------------
#  Erros:
#    - Caso de erro na chave na hora de adicionar o repositório do Kubernetes, roda esse comando:
#       >> "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CHAVE_AUSENTE"
#    - Na hora da criação do cluster pode ter erro relacionado ao conteúdo do arquivo 
#		/proc/sys/net/ipv4/ip_forward não está definido como 1, o que é necessário para que o
# 		Kubernetes funcione corretamente! Para resolver, entre no user root (sudo su) e rode esse comando:
# 		<echo "1" > /proc/sys/net/ipv4/ip_forward>
# ------------------------------------------------------------------------- #
# Testado em:
#   bash 5.1.16
# ------------------------------------------------------------------------- #

# -------------------------------- IMPORTAÇÕES -------------------------------- #
source libs/functions_deps.sh
source libs/functions_main.sh
source libs/details.sh
# ------------------------------------------------------------------------- #

# -------------------------------- FUNÇÕES -------------------------------- #
function trapped () {
	echo -e "${COR_VERMELHO}Erro na linha $1${COR_RESET}"
	exit 1
}
trap 'trapped $LINENO' ERR

# FUNÇÃO PRINCIPAL
function install_kubernetes () {
	clear
	while true; do
		_title "SCRIPT DE INSTALAÇÃO DO KUBERNETES"
		echo -e "                ${COR_CIANO}MENU DE OPÇÕES${COR_RESET}"
		_line
		echo -e "${COR_VERDE}1.${COR_RESET} Instalar Dependências."
		echo -e "${COR_VERDE}2.${COR_RESET} Iniciar o Cluster."
		echo -e "${COR_VERDE}3.${COR_RESET} Escolher a CNI do Kubernetes."
		echo -e "${COR_VERDE}4.${COR_RESET} Informações do Cluster."
		echo -e "${COR_VERDE}5.${COR_RESET} Token de conexão com workers."
		echo -e "${COR_VERDE}6.${COR_RESET} Desconectar um worker de um cluster."
		echo -e "${COR_VERDE}7.${COR_RESET} Ajuda."
		echo -e "${COR_VERDE}8.${COR_RESET} Sair."
		_line
		
		read -p "Escolha uma opção: " option
		_line
    
    case $option in
        1)
            echo -e "${COR_VERDE}Instalar Dependências.${COR_RESET}"
			sleep 1
			clear
            _install_deps
			sudo apt update
            ;;
        2)
			echo -e "${COR_VERDE}Iniciando o Cluster.${COR_RESET}"
			sleep 1
			sudo su -c 'echo "1" > /proc/sys/net/ipv4/ip_forward'
			clear
            _start
			sleep 1
            ;;
        3)
			echo -e "${COR_VERDE}CNI do Kubernetes.${COR_RESET}"
			sleep 1
			clear
			_cni
			sleep 1
            ;;
        4)
            echo -e "${COR_VERDE}Informações do Cluster.${COR_RESET}"
			sleep 1
			clear
			_info
            ;;
		5)
            echo -e "${COR_VERDE}Token de conexão com workers.${COR_RESET}"
			sleep 1
			clear
			_generate_token
            ;;
		6)
            echo -e "${COR_VERDE}Desconectar um worker de um cluster.${COR_RESET}"
			sleep 1
			clear
			_disconect_worker
            ;;
		7)
            echo -e "${COR_VERDE}Menu de Ajuda.${COR_RESET}"
			sleep 1
			clear
			_help
            ;;
		8)
            echo -e "${COR_VERDE}Saindo...${COR_RESET}"
			sleep 1
			clear
			exit
            ;;
        *)
            echo -e "${COR_VERMELHO}Opção inválida. Por favor, escolha uma opção válida.${COR_RESET}"
            ;;
    esac
    
	_line
    read -p "Pressione Enter para continuar..."
	clear
done

}
# ------------------------------------------------------------------------- #

# -------------------------------- EXECUÇÃO -------------------------------- #
while [ -n "$1" ]; do
	case "$1" in
		-m|--menu)                install_kubernetes;   exit ;;
		-d|--deps)                _install_deps;   	    exit ;;
		-s|--start)               _start;   	        exit ;;
		-c|--cni)              	  _cni;         	    exit ;;
		-t|--token)               _generate_token; 	    exit ;;
		-w|--disconect_worker)    _disconect_worker; 	exit ;;
		-a|--alias)               _alias;               exit ;;
		-i|--info)                _info;                exit ;;
		-h|--help)                _help;                exit ;;
		*)                        _error "$1"                ;; 
	esac
done

install_kubernetes