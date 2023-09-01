# COR RESET
COR_RESET='\033[0m'

# CORES DE TEXTO
COR_PRET0='\033[0;30m'
COR_VERMELHO='\033[0;31m'
COR_VERDE='\033[0;32m'
COR_AMARELO='\033[0;33m'
COR_AZUL='\033[0;34m'
COR_MAGENTE='\033[0;35m'
COR_CIANO='\033[0;36m'
COR_BRANCO='\033[0;37m'

# CORES DE FUNDO
BG_COR_PRET0='\033[0;40m'
BG_COR_VERMELHO='\033[0;41m'
BG_COR_VERDE='\033[0;42m'
BG_COR_AZUL='\033[0;44m'
BG_COR_MAGENTE='\033[0;45m'
BG_COR_CIANO='\033[0;46m'
BG_COR_BRANCO='\033[0;47m'

# MODOS ASI
NORMAL='\033[0;0m'
NEGRITO='\033[0;1m'
BAIXA_INTENSID='\033[0;2m'
ITALICO='\033[0;3m'
SUBLINHADO='\033[0;4m'
PISCANDO='\033[0;5m'
PISCA_RAPIDO='\033[0;6m'
INVERSO='\033[0;7m'
INVISIVEL='\033[0;8m'

function _line () {
	echo -e "${COR_AMARELO}==============================================${COR_RESET}"
}

function _line_long () {
	echo -e "${COR_VERDE}-----------------------------------------------------------------------------${COR_RESET}"
}

function _title () {
	text="$1"
    tam=${#text}
    border=$(printf '%0.s=' $(seq 1 "$((tam + 12))"))

    printf "${COR_AMARELO}%s${COR_RESET}\n" "$border"
    printf "${COR_AMARELO}%-*s${COR_RESET}\n" "$((tam + 42))" "----- $text -----"
    printf "${COR_AMARELO}%s${COR_RESET}\n" "$border"
}
