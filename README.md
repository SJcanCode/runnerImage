# runnerImage

A Dockerbuild file to setup github runner with user able to use sudo. 
notes: some time you may want your action to run some sudo command. 

e.g.
At action yml add 
echo ${{secrets.SUDOPASSWD}} | sudo -S apt-get install snapd -y
