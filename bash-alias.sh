#!/bin/bash

### Main file that executes bash-alias

# Prints usage of this program
usage() {
  echo "Manage various alias profiles."
  echo "Usage: $(basename "$0") [OPTION]..."
  echo ""
  echo "-p <profile>"
  echo -e "\t profile to be modified"
  echo "-i"
  echo -e "\tinstalls this program."
  echo "-u"
  echo -e "\tuninstalls this program."
  echo "-c <profile>"
  echo -e "creates a new alias profile."
  echo "-d <profile>"
  echo -e "deletes an existing alias profile."
  echo "-a <alias={cmd}>"
  echo -e "\tadds a new alias to an existing profile."
  echo "-r <alias>"
  echo -e "\tremoves an alias from an existing profiles."
  echo "-o <alias>"
  echo -e "\tactivates a profile."
  echo "-f <alias>"
  echo -e "\tdeactivates a profile."
  echo "-l <profile>"
  echo -e "\tlists all existing alias from the given profile"
  echo "-s"
  echo -e "\tclears all cassandra nodes executing"
}

data_dir=~/alias
profile=default

# Main loop to parse flags
while getopts ':p: c: d: a: r: o: f: l: s' opt; do
  case "$opt" in
  p)
    profile="$OPTARG"
    ;;
  c)
    create="$OPTARG"
    ;;
  d)
    delete="$OPTARG"
    ;;
  a)
    add="$OPTARG"
    ;;
  r)
    remove="$OPTARG"
    ;;
  o)
    activate="$OPTARG"
    ;;
  f)
    deactivate="$OPTARG"
    ;;
  l)
	  list="$OPTARG"
    ;;
  s)
	  show=1
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

# Commands


# Creates a new alias profile in folder alias
if [[ ! -z "$create" ]]; then

  if [[ -f "$data_dir/$create.alias" ]]; then
  
    echo "Profile $create already created!"
    exit 1
  
  else
  
    echo -e "#!/bin/bash\n\n$create=1\n\nif [  \$"$create" -eq 1 ]; then\n\t#+\n\t#-\nfi\n\nunset "$create"" >> $data_dir/$create.alias
    echo "Created new profile $create."
  
  fi
fi

# Deletes an existing profile
if [[ ! -z "$delete" ]]; then

  if [[ ! -f "$data_dir/$delete.alias" ]]; then
    
    echo "Profile $delete doesn't exist!"
    exit 2
  
  else
  
    rm $data_dir/$delete.alias
    echo "Removed file $delete.alias."

    echo "Removed profile $delete!"

  fi
fi


# Adds a new alias to a provided profile. If none is provided, alias goes to default.alias
if [[ ! -z "$add" ]]; then

  if [[ ! -f "$data_dir/$profile.alias" ]]; then
    
    echo "Profile $profile doesn't exist!"
    exit 3
  
  else
    # Split the alias at =
    IFS='=' read -r alias_name alias_cmd <<< "$add"

    # Escape any spaces in the alias or sed doesn't work
    alias_cmd=$( echo "$alias_cmd" | sed 's/ /\\ /g' )

    # Add to the provided profile
    sed -i "s/\t#+/\t#+\n\talias\ $alias_name=\"$alias_cmd\"/g" $data_dir/$profile.alias
    echo "Added '$add' to $profile.alias!"
  
  fi
fi

# Removes an existing alias of a profile. If none is provided, deletes from default.alias
if [[ ! -z "$remove" ]]; then

  if [[ ! -f "$data_dir/$profile.alias" ]]; then
    
    echo "Profile $profile doesn't exist!"
    exit 4
  
  else

    if [[ $profile -eq "default" ]]; then
      echo "Can't remove default profile!"
      exit 10
    fi
    
    if ! grep -n -q "$remove" $data_dir/$profile.alias; then
      echo "$remove doesn't exist in profile $profile!"
    
    else
      
      sed -i "/$remove/d" $data_dir/$profile.alias

      echo "Removed $remove from $profile.alias!"
    
    fi 
  fi
fi

# Activates an existing alias profile
if [[ ! -z "$activate" ]]; then
  
  if [[ ! -f "$data_dir/$activate.alias" ]]; then
    
    echo "Profile $activate doesn't exist!"
    exit 5
  
  else
    sed -i "s/$activate=0/$activate=1/g" $data_dir/$activate.alias
    echo "Profile $activate activated!"
  fi
fi

# Deactivates an existing alias profile
if [[ ! -z "$deactivate" ]]; then

  if [[ ! -f "$data_dir/$deactivate.alias" ]]; then
    
    echo "Profile $deactivate doesn't exist!"
    exit 6
  
  else
    sed -i "s/$deactivate=1/$deactivate=0/g" $data_dir/$deactivate.alias
    echo "Profile $deactivate deactivated!"
  fi
fi

# Prints the alias of the provided alias profile
if [[ ! -z "$list" ]]; then

  if [[ ! -f "$data_dir/$list.alias" ]]; then
    
    echo "Profile $list doesn't exist!"
    exit 7
  
  else
    
    cat $data_dir/$list.alias
    exit 0

  fi
fi

# Lists all existing profiles and their active status
if [[ ! -z "$show" ]]; then

  for prof in $data_dir/*; do

    if [ -f "$prof" ]; then

      IFS='.' read -r alias_name alias_rest <<< $(basename "$prof")
      grep -m 1 "$alias_name" $prof

    fi
  done
fi

# Sources bashrc to ensure the changes made are imediate
source ~/.bashrc
echo "Reload complete!"
