Welcome i appreciate your valuable time the project is up and running on the following link

	http://AKNP-1014054250.us-east-2.elb.amazonaws.com

	Besides i leave the steps to configure a new infrastructure

Step 1: 

	Install on your local computer/server the app Terraform and made all the configuration including the environment variables

Step 2: 

	After the installation download the project from my git repository

	Git://

Step 3:

	Open the console (windows in this case) and move inside the folder "Challenge_Acklen" 

Step 4: 

	Execute the command "terraform init" inside of the folder, you will receive a message like this.

		Initializing the backend...

		Initializing provider plugins...
		- Reusing previous version of hashicorp/aws from the dependency lock file

		Terraform has been successfully initialized!

		You may now begin working with Terraform. Try running "terraform plan" to see
		any changes that are required for your infrastructure. All Terraform commands
		should now work.

		If you ever set or change modules or backend configuration for Terraform,
		rerun this command to reinitialize your working directory. If you forget, other
		commands will detect it and remind you to do so if necessary.


Step 5:

	Run the command "terraform validate" after the execution you must receive a message that says "Success!" The configuration is valid

		!!!!! Inside the File Challenge.tf you will find the comments to replace some parameters

Step 6:

	Run the command "terraform apply" to apply all the infrastructure and prepare the servers

Step 7:

	Install Ansible on your local computer or server with the following commands for ubuntu

		sudo apt-get install software-properties-common
		sudo apt-add-repository ppa:ansible/ansible
		sudo apt-get update
		sudo apt-get install ansible

Step 8: 

	Locate the public ips of the instances and run the following command for each ip

		example:  ssh -o stricthostkeychecking=no 18.218.51.133

Step 9: 

	Run this command "sudo vi /etc/ansible/hosts" and Add the public ip's of the servers

Step 10: 
	
	Run this command "sudo vi /etc/ansible/insakn.yml" and Add the following including the 3 dashes and save the file

---                                                                                                                                                                                                                                                                                                                                             - hosts: all                                                                                                                                                              become: true                                                                                                                                                            tasks:                                                                                                                                                                          - name: Actualizar paqueteria                                                                                                                                             apt: update_cache=yes                                                                                                                                                                                                                                                                                                                         - name: Instalar NodeJS                                                                                                                                                   apt:  name=nodejs state=latest                                                                                                                                          ignore_errors: yes                                                                                                                                                                                                                                                                                                                            - name: Instalar npm                                                                                                                                                      apt: name=npm state=latest                                                                                                                                              ignore_errors: yes                                                                                                                                                                                                                                                                                                                            - name: Instalar pm2                                                                                                                                                      npm: name=pm2 global=yes production=yes                                                                                                                                 ignore_errors: yes                                                                                                                                                                                                                                                                                                                            - name: Instalar Git                                                                                                                                                      apt:  name=git state=latest                                                                                                                                             ignore_errors: yes                                                                                                                                                                                                                                                                                                                            - name: Crear AppDirectory                                                                                                                                                file:                                                                                                                                                                       path: /home/ubuntu/ChatApp                                                                                                                                              state: directory                                                                                                                                                                                                                                                                                                                          - name: ClonarRepo deGit                                                                                                                                                  git:                                                                                                                                                                        repo: https://github.com/abkunal/Chat-App-using-Socket.io.git                                                                                                           dest: /home/ubuntu/ChatApp                                                                                                                                              update: yes                                                                                                                                                             force: yes                                                                                                                                                                                                                                                                                                                                - name: Correr NPM en la direccion actual                                                                                                                                 npm:                                                                                                                                                                        path: /home/ubuntu/ChatApp                                                                                                                                              state: latest                                                                                                                                                                                                                                                                                                                             - name: Detener APP PM2                                                                                                                                                   command: pm2 stop /home/ubuntu/ChatApp/app.js                                                                                                                           ignore_errors: yes                                                                                                                                                                                                                                                                                                                            - name: Arrancar APP Pm2                                                                                                                                                  command: pm2 start /home/ubuntu/ChatApp/app.js                                                                                                                          ignore_errors: yes                                                                                                                                          

Step 11:

	run the following command and replace the address of the private key where is located your pem file

		ansible-playbook /etc/ansible/insakn.yml -u ubuntu --private-key /home/neto/AKN_KEY.pem    

Step 12: 

	Go to aws load balancer and copy the DNS Name and paste it on your web browser