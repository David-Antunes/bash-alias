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
  echo "-l <profile>"
  echo -e "\tlists all existing alias from the given profile"
  echo "-s"
  echo -e "\tclears all cassandra nodes executing"
}

data_dir=alias
profile=default

# Main loop to parse flags
while getopts 'p: iu c:d: a: r: l: s' opt; do
  case "$opt" in
  p)
    profile="$OPTARG"
    ;;
  i)
    install=1
    ;;
  u)
    uninstall=1
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

# Restrictions

if [[ ! -z "$install" ]]; then
  
  # Check if the program as already been added to bashrc
  if ! grep -n -q "$prog" ~/.bashrc ; then
    echo -e "\nsource $(pwd)/bash-alias" >> ~/.bashrc
  fi

  echo "Added bash-alias to bashrc."

  if [[ ! -d $data_dir ]]; then 

    mkdir -p $data_dir
    echo "Created data folder."
    
    touch $data_dir/default.alias
    echo "Created default.alias"
    
  fi
 
  echo "Bash-alias as been installed."

fi

if [[ ! -z "$uninstall" ]]; then

  prog=bash-alias
  
  if grep -n -q "$prog" ~/.bashrc ; then
    sed -i "/$prog/d" ~/.bashrc
  fi
  
  unset prog
  
  echo "Uninstalled bash-alias to bashrc."
  echo "If you want to start from scratch, delete $data_dir folder in $(pwd)/$data_dir."

fi

if [[ ! -z "$create" ]]; then

  if [[ -f "$data_dir/$create.alias" ]]; then
  
    echo "Profile $create already created!"
    exit 1
  
  else
  
    echo -e "$create=1\nif [[ ! -z "$create" ]]; then\n#+\n#-\nfi" >> $data_dir/$create.alias
    echo "Created new profile $create."
  
  fi
fi

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

if [[ ! -z "$add" ]]; then

  if [[ ! -f "$data_dir/$profile.alias" ]]; then
    
    echo "Profile $profile doesn't exist!"
    exit 3
  
  else

    echo "$add" >> $data_dir/$profile.alias
    sed -i "s/#+/#+\n$add/g" $data_dir/$profile.alias
    echo "Added $add to $profile.alias!"
  
  fi
fi


if [[ ! -z "$remove" ]]; then

  if [[ ! -f "$data_dir/$profile.alias" ]]; then
    
    echo "Profile $profile doesn't exist!"
    exit 4
  
  else
    
    if ! grep -n -q "$remove" $data_dir/$profile.alias; then
      echo "$remove doesn't exist in profile $profile!"
    
    else
      
      sed -i "/$remove/d" $data_dir/$profile.alias

      echo "Removed $remove from $profile.alias!"
    
    fi 
  fi
fi

if [[ ! -z "$activate" ]]; then
  
  if [[ ! -f "$data_dir/$activate.alias" ]]; then
    
    echo "Profile $activate doesn't exist!"
    exit 5
  
  else
    sed -i "s/$activate=.?/$activate=1" $data_dir/$activate.alias
    echo "Profile $activate activated!"
  fi
fi

if [[ ! -z "$deactivate" ]]; then

  if [[ ! -f "$data_dir/$deactivate.alias" ]]; then
    
    echo "Profile $deactivate doesn't exist!"
    exit 6
  
  else
    sed -i "s/$deactivate=.?/$deactivate=0" $data_dir/$deactivate.alias
    echo "Profile $deactivate deactivated!"
  fi
fi

if [[ ! -z "$list" ]]; then

  if [[ ! -f "$data_dir/$profile.alias" ]]; then
    
    echo "Profile $profile doesn't exist!"
    exit 7
  
  else
    
    cat $data_dir/$profile.alias
    exit 0

  fi
fi

if [[ ! -z "$show" ]]; then

  for prof in $data_dir/*; do

    if [ -f "$prof" ]; then
      
      echo $prof
      cat $data_dir/$prof
      echo ""
    
    fi
  done
fi
