git config --global user.name "luvres"
git config --global user.email "luvres@hotmail.com"

ssh-keygen
cat $HOME/.ssh/id_rsa.pub | xclip -sel clip # $HOME/.ssh/config
ssh -T git@github.com
ssh -T -p443 git@ssh.github.com

git config --global credential.helper cache
git add .
git commit -am "Primeiro commit"
git push

git config --list

##############################
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
git config --global credential.helper 'cache --timeout=86400'

ssh-keygen

cat ~/.ssh/id_rsa.pub | xclip -sel clip 
# ~/.ssh/config

echo 'Host github.com' >> ~/.ssh/config
echo '  Hostname ssh.github.com' >> ~/.ssh/config
echo '  Port 443' >> ~/.ssh/config
  
ssh -T git@github.com
ssh -T -p443 git@ssh.github.com

git init /git

git add .
git commit -m "Primeiro commit"
git commit -a -m "Primeiro commit"
git commit -amend -m "Commit (edicao)"

git remote add upstream https://github.com/FreeCAD/FreeCAD.git
git fetch upstream #sincronizar os repositórios
git merge upstream/master

git remote set-url origin https://github.com/luvres/CalculiX-2.10.git

git clone git@github.com:user/projeto

git remote      //lista os servidores remoto
git push origin master  //envia do brunch master para o servidor origin
git pull origin master  //trazer dados do origin para master


git reset HEAD arquivo.txt	//remove arquivo que foi add
git checkout --arquivo.txt	//retorna alteracoes salvas que nao foi add
git rm arquivo.txt		//remove arquivo do repositorio

git log			//historico de todos os commits em ordem cronologica
git log -p		//alem do historico mostra o que foi alterado
git log -p -2		//numero de commits a ser mostrado por ultimo
git log --pretty=oneline	//mostra somente o codigo da cada commit e a msg

git diff		//mostra alteracoes feitas antes do add
git diff --staget	//mostra alteracoes feitas apos o add (stagearea)

git tag -a v1.0 -m "Versao 1.0"	//cria uma tag

git log --pretty=oneline
git tag -a v0.0 f098efd-098df9809f77 -m "Versao 0.0"	//cria tag de commit antigo

git show v0.0
git checkout v0.0	//ativar tag v0.0
git tag -d v1.0		//deletar tag

git branch teste	//criar ambiente de nome teste
git checkout teste	//ativar os arquivos para o ambiente teste
  ou
git checkout -b teste	//comando unico aos dois anteriores

git checkout master	//voltar para o ambiente principal
git merge teste		//update do ambiente teste para ambiente atual
git branch -d teste	//deleta ambiente teste, fora do mesmo
git branch	//listar todos os branch (ambientes) do repositorio

git clone file:////server/projeto1 projeto

git push commit origin master	//envia do brunch master para o github
git pull origin master	//quando troca de diretorio



