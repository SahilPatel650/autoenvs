# autosource_env_venv.plugin.zsh

# autosource_venv.plugin.zsh

# Check if running in Visual Studio Code integrated terminal
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # Exit the script early if in VS Code
    return
fi


# Settings
# Ensure ENV_VARS is properly declared as a global associative array
if [[ ${(t)ENV_VARS} != "association-global" ]]; then
    unset ENV_VARS
    typeset -g -A ENV_VARS
fi

: ${ZSH_DOTENV_FILE:=.env}
: ${ZSH_VENV_DIR:=.venv}
: ${ZSH_DOTENV_ALLOWED_LIST:="${ZSH_CACHE_DIR:-$ZSH/cache}/dotenv-allowed.list"}
: ${ZSH_DOTENV_DISALLOWED_LIST:="${ZSH_CACHE_DIR:-$ZSH/cache}/dotenv-disallowed.list"}
: ${ZSH_VENV_ALLOWED_LIST:="${ZSH_CACHE_DIR:-$ZSH/cache}/venv-allowed.list"}
: ${ZSH_VENV_DISALLOWED_LIST:="${ZSH_CACHE_DIR:-$ZSH/cache}/venv-disallowed.list"}

# Initialize the allowed and disallowed lists if they don't exist
mkdir -p "${ZSH_CACHE_DIR:-$ZSH/cache}"
touch "$ZSH_DOTENV_ALLOWED_LIST" "$ZSH_DOTENV_DISALLOWED_LIST" "$ZSH_VENV_ALLOWED_LIST" "$ZSH_VENV_DISALLOWED_LIST"

# Stack to track currently sourced environments
if [[ ${(t)ENV_STACK} != "array-global" ]]; then
    unset ENV_STACK
    typeset -g -a ENV_STACK
fi

if [[ ${(t)VENV_STACK} != "array-global" ]]; then
    unset VENV_STACK
    typeset -g -a VENV_STACK
fi

# Function to activate a virtual environment
activate_venv() {
    local venv_path="$1"
    if [[ -d "$venv_path" ]]; then
        source "$venv_path/bin/activate"
        VENV_STACK+=("$venv_path")
    fi
}

# Function to deactivate the last activated virtual environment
deactivate_venv() {
    if [[ "${#VENV_STACK[@]}" -gt 0 ]]; then
        deactivate 2>/dev/null
        unset "VENV_STACK[-1]"
    fi
}

# Function to source a .env file and track the variables it sets
source_env_file() {
    local env_file="$1"
    local key value

    if [[ ${(t)ENV_VARS} != "association-global" ]]; then
        unset ENV_VARS
        typeset -g -A ENV_VARS
    fi

    if [[ -f "$env_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" == \#* ]] && continue
            key="${line%%=*}"
            key="${key## }"
            key="${key%% }"
            [[ -z "$key" ]] && continue
            ENV_VARS["$key"]="${(P)${key}:-}"
        done < "$env_file"

        setopt localoptions allexport
        source "$env_file"
        unsetopt allexport
        ENV_STACK+=("$env_file")
    fi
}

# Function to unsource variables specific to the last sourced .env file
unsource_env_file() {
    local last_file="${ENV_STACK[-1]}"
    local key value

    if [[ ${(t)ENV_VARS} != "association-global" ]]; then
        unset ENV_VARS
        typeset -g -A ENV_VARS
    fi

    if [[ -f "$last_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" == \#* ]] && continue
            key="${line%%=*}"
            key="${key## }"
            key="${key%% }"
            [[ -z "$key" ]] && continue
            if [[ -n "${ENV_VARS[$key]+x}" ]]; then
                export "$key"="${ENV_VARS[$key]}"
                unset "ENV_VARS[$key]"
            else
                unset "$key"
            fi
        done < "$last_file"
        unset "ENV_STACK[-1]"
    fi
}

# Main function to manage both .env and venv activation/deactivation
manage_env_and_venv() {
    local env_file="$PWD/$ZSH_DOTENV_FILE"
    local venv_path="$PWD/$ZSH_VENV_DIR"
    local dirpath="${PWD:A}"

    if [[ ${(t)ENV_VARS} != "association-global" ]]; then
        unset ENV_VARS
        typeset -g -A ENV_VARS
    fi

    if [[ "${#VENV_STACK[@]}" -gt 0 && "${VENV_STACK[-1]}" != "$venv_path" ]]; then
        deactivate_venv
    fi

    if [[ "${#ENV_STACK[@]}" -gt 0 && "${ENV_STACK[-1]}" != "$env_file" ]]; then
        unsource_env_file
    fi

    if [[ -f "$env_file" && ! $(grep -Fxq "$dirpath" "$ZSH_DOTENV_DISALLOWED_LIST") ]]; then
        if ! grep -Fxq "$dirpath" "$ZSH_DOTENV_ALLOWED_LIST"; then
            local env_confirmation
            echo -n "Source '$env_file'? ([y]/[n]/[a]lways/n[e]ver) "
            read -k 1 env_confirmation
            echo

            case "$env_confirmation" in
                [nN]) ;;
                [aA]) echo "$dirpath" | tee -a "$ZSH_DOTENV_ALLOWED_LIST" >/dev/null; source_env_file "$env_file" ;;
                [eE]) echo "$dirpath" | tee -a "$ZSH_DOTENV_DISALLOWED_LIST" >/dev/null;;
                *) source_env_file "$env_file" ;;
            esac
        else
            source_env_file "$env_file"
        fi
    fi

    if [[ -d "$venv_path" && ! $(grep -Fxq "$dirpath" "$ZSH_VENV_DISALLOWED_LIST") ]]; then
        if ! grep -Fxq "$dirpath" "$ZSH_VENV_ALLOWED_LIST"; then
            local venv_confirmation
            echo -n "Activate '$venv_path'? ([y]/[n]/[a]lways/n[e]ver) "
            read -k 1 venv_confirmation
            echo

            case "$venv_confirmation" in
                [nN]) ;;
                [aA]) echo "$dirpath" | tee -a "$ZSH_VENV_ALLOWED_LIST" >/dev/null; activate_venv "$venv_path" ;;
                [eE]) echo "$dirpath" | tee -a "$ZSH_VENV_DISALLOWED_LIST" >/dev/null;;
                *) activate_venv "$venv_path" ;;
            esac
        else
            activate_venv "$venv_path"
        fi
    fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd manage_env_and_venv
manage_env_and_venv
