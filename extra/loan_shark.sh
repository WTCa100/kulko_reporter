#!/bin/bash

PROGNAME=$(basename $0)

usage() {
    message="$(cat << EOF
Usage: $PROGNAME  [-i|[-p <int> -r <float> -n <int>]|-h]
example usage: 
$PROGNAME -p 25000 -r 0.07 -n 120
$PROGNAME -i

i - interactive mode
p - initial value of money invested
r - intrest rate (n% = n / 100 -> 6% = 0.06)
n - how many payments is foreseen
h - help
EOF
)"
    echo "$message" 1>&2
}

is_int()
{
    if [[ $1 =~ ^-?[[:digit:]]+$ ]]; then
        echo 1
        return
    fi
    echo 0
}

is_float()
{
    if [[ $1 =~ ^-?[[:digit:]]+\.[[:digit:]]+$ ]]; then
        echo 1
        return
    fi
    echo 0
}

get_input_int()
{
    valid=0
    until (( valid == 1 )); do
        read -r -p "Please provide an integer value:"

        if [[ $(is_int $REPLY) -eq 1 ]]; then
            valid=1
        fi
    done
    echo $REPLY
}

get_input_float()
{
    valid=0
    until (( valid == 1 )); do
        read -r -p "Please provide a floating point value:"
        if [[ $(is_float $REPLY) -eq 1 ]]; then
            valid=1
        fi
    done
    echo $REPLY
}

interactive=0
intrest=
initial_payment=
months=

while getopts ":ip:r:n:h" option; do
    case "$option" in
        h) 
            usage && exit 0
            ;;
        i)
            if [[ -n $months || -n $intrest || -n $initial_payment ]]; then
                echo "Debug: Invalid use of parameters"
                usage && exit 1
            fi
            interactive=1
            ;;
        [pn])
            if [[ $interactive -eq 1 ]]; then
                echo "Debug: Invalid use of parameters"
                usage && exit 1
            fi

            if [[ $(is_int $OPTARG) -eq 0 ]]; then
                usage && exit 1;
            fi

            if [[ $option == 'n' ]]; then
                months="${OPTARG}"
            else
                initial_payment="${OPTARG}"
            fi
            ;;
        r)
            if [[ interactive -eq 1 ]]; then
                echo "Debug: Invalid use of parameters"
                usage && exit 1
            fi
            if [[ $(is_float $OPTARG) -eq 0 ]]; then
                usage && exit 1
            fi
            intrest="${OPTARG}"
            ;;
        *)
            usage && exit 1
            ;;
    esac
done

if (( $interactive == 1 )); then
    echo "What is the initial \$ input?"
    initial_payment="$(get_input_int)"
    echo "What is the intrest rate?"
    intrest="$(get_input_float)"
    echo "What is the amount of payments?"
    months="$(get_input_int)"
fi

echo "Calculation values={p=${initial_payment} i=${intrest} n=${months}}"
if [[ -z "${initial_payment}" || -z "${intrest}" || -z "${months}" ]]; then
    usage && exit 1
fi

#  scale - special variable that give the precision to the final answer
result="$(bc <<- EOF
scale = 10
p = $initial_payment
i = $intrest / 12
n = $months

a = p * ((i * ((1 + i) ^ n)) / (((1 + i) ^ n) - 1))
print a, "\n"
EOF
)"
printf "You shall ensure mothly payments of:\n%.02f\n" "$result"
