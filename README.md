# Deploing a Web server in Azure. Infrastructure as a code (Terraform and Packer) 

### Goal of this project

Goal of this project is to create an Infrastructire as a code to deploy Azure resources for a web server in a declarative way, which will allow to automate deployment process. To do so Terraform and Packer tools were used. Packer is a tool, to create VM's image and deploy it in the Azure Cloud. Terraform is a tool, which allows declaratively deploy resources in the cloud. Files of Terraform and Packer can be used as template's for the future resource deployment or changing existing deployed resources.

### Project's file structure

- **main.tf**      - Terraform file, where all resources are declared 
- **variables.tf** - Terraform file, where parameters of resources are given as variables
- **policy.json**  - Microsoft Azure Cloud resource policy, which doesn't allow for resources to be deployed without tags
- **server.json**  - Packer VM's image configuration file

### Terraform commands 

Here are just some of the crucial commands given. The whole list of the commands can be found [here](https://www.terraform.io/docs/cli/commands/index.html).   

>- **terraform init**     - Prepare your working directory for other commands
>- **terraform validate** - Check whether the configuration is valid
>- **terraform plan**     - Show changes required by the current configuration
>- **terraform apply**    - Create or update infrastructure
>- **terraform destroy**  - Destroy previously-created infrastructure


### Packer commands 

Here are just some of the crucial commands given. The whole list of the commands can be found [here](https://www.packer.io/docs/commands).   

>- **packer init**     - will list all installed plugins then download the latest versions for the ones that are missing.
>- **packer build**    - takes a template and runs all the builds within it in order to generate a set of artifacts

### Terraform installation

- In terms of being able to run **az** commands for Azure, [Azure-CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli) should be installed first. This will allow to connect to Azure account and run Azure-CLI commands from command prompt.
- After that,  [terraform.exe](https://www.terraform.io/downloads.html) file should be downloaded according to your operating system and added to environment variable path of your computer. 
- To check that Terraform is installed -> open command prompt and run **terraform -version** command, which should print an installed version of Terraform.    

### Packer installation

-  [packer.exe](https://www.packer.io/downloads) file should be downloaded according to your operating system and added to environment variable path of your computer. 
- To check that Packer is installed -> open command prompt and run **packer -version** command, which should print an installed version of Packer. 

### Terraform resource adjusting

- In terms of changing the parameters of Azure resources such as **VM user name**, **VM user password**, **prefix of resources**, etc. **variables.tf** file should be adjusted.  
- To add resources **main.tf** file should be changed.

### VM image parameters adjusting

- To change the type, size of the  image **server.json** file should be changed. 