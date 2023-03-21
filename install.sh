#!/bin/bash
usage() { echo "Manage various alias profiles."
  echo "Usage: $(basename "$0") [OPTION]..."
  echo "-i"
  echo -e "\tinstalls this program."
  echo "-u"
  echo -e "\tuninstalls this program."
}

while getopts 'iu' opt; do
  case "$opt" in
  i)
    install=1
    ;;
  u)
    uninstall=1
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

install_dir=~/.config/bash-alias
script_dir=~/.scripts

if [[ ! -z "$install" ]]; then
  
  # Check if the program as already been added to bashrc
  if ! grep -n -q "bash-alias" ~/.bashrc ; then
    echo -e "source $install_dir/bash-alias" >> ~/.bashrc
  fi

  echo "Added bash-alias to bashrc."

  if [[ ! -d $install_dir ]]; then 

    mkdir -p $install_dir
    echo "Created $install_dir folder."

    cp bash-alias $install_dir/bash-alias
    cp bash-alias.sh $install_dir/bash-alias.sh
    
    sed -i "s|alias_path=.*|alias_path=$install_dir/alias|g" $install_dir/bash-alias
    sed -i "s|data_dir=.*|data_dir=$install_dir/alias|g" $install_dir/bash-alias.sh
    echo "Copied program files."

    ln -s ~/.config/bash-alias/bash-alias.sh $script_dir/bash-alias.sh
    echo "Created Symlink for bash-alias to .scripts folder."

    mkdir -p $install_dir/alias
    echo "Created alias folder."
    
    echo -e "#!/bin/bash\n\ndefault=1\n\nif [  \$default -eq 1 ]; then\n\t:\n\t#+\n\t#-\nfi\n\nunset default" > $install_dir/alias/default.alias 
    
    echo "Created default.alias"
    
  else
    ln -s ~/.config/bash-alias/bash-alias.sh $script_dir/bash-alias.sh
  fi
  echo "Bash-alias as been installed."

fi

if [[ ! -z "$uninstall" ]]; then

  if grep -n -q "bash-alias" ~/.bashrc ; then
    sed -i "/bash-alias/d" ~/.bashrc
    rm $script_dir/bash-alias.sh
  fi
  
    echo "Uninstalled bash-alias to bashrc."
    echo "If you want to start from scratch, delete alias folder in $install_dir."

fi

