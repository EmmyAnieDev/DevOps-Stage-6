[app_servers]
app_server ansible_host=${server_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${ssh_private_key_path} ansible_python_interpreter=/usr/bin/python3 ansible_become=yes
