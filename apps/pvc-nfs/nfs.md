mkdir /mnt/nfs

sudo apt-get install nfs-kernel-server nfs-common

sudo vi /etc/exports

# add in /etc/exports
/mnt/nfs *(rw,sync,no_root_squash,no_subtree_check)

/mnt/nfs: é o diretório que você deseja compartilhar.

# *: permite que qualquer host acesse o diretório compartilhado. Para maior segurança, você pode substituir * por um intervalo de IPs ou por IPs específicos dos clientes que terão acesso ao diretório compartilhado. Por exemplo, 192.168.1.0/24 permitiria que todos os hosts na sub-rede 192.168.1.0/24 acessassem o diretório compartilhado.
# rw: concede permissões de leitura e gravação aos clientes.
# sync: garante que as solicitações de gravação sejam confirmadas somente quando as alterações tiverem sido realmente gravadas no disco.
# no_root_squash: permite que o usuário root em um cliente NFS acesse os arquivos como root. Caso contrário, o acesso seria limitado a um usuário não privilegiado.
# no_subtree_check: desativa a verificação de subárvore, o que pode melhorar a confiabilidade em alguns casos. A verificação de subárvore normalmente verifica se um arquivo faz parte do diretório exportado.

# then 

sudo exportfs -arv


# check NFS
showmount -e