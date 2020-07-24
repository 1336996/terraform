How to use a file in terraform script.
1. Make a file. Keep it in the same directory where the terraform file is.
2. command is ${file("file_name")}
e.g-> userdata= ${file("file_name")}


How to use Variable in terraform(Teraform support 3 types of variable list, string, map)
1. Create a variable file with the name variable.tf
2. Varible files looks like
   variable "ami" {
    default="ami_id"
   }

3. In terraform variable will be used as.
   resource "aws_instance" "my" {
     ami = "${var.ami}"
   }
#if we declare the variable in variable file but dont assign any default value, then it will take the value of that variable from console from the user.


How to declare list variable?
1. variable "subnets_cidr" {
     type="list"
     default=["10.20.1.0/24",10.20.2.0/24"]
   }
2. In terraform variable will be used as.
   resource "aws_instance" "my" {
     ami = "${elements(var.subnets_cidr,count.index)}"
   }

How to use provider.
provider "aws" {
  aws_region= us-east-1"
}
#Always keep this provider in seperate file name as provider.tf

How to use created resource in same terraform script.
"${resourcename.logicalname.attribute}"

What is Terraform Lookup function.
syntax -> lookup(map,key,[default])
e.g -> variable.tf
variable "ami" {
    type=map

    default= {
      us-east-2="ami_id"
      us-east-1="ami_id2"
   }
}
main.tf
resource "aws_instance" "my" {
     ami = "${lookup(var.ami,var.aws_region)}"
}



To check what exactly a variable is returning.
1. Use command-> terraform console
2. type the variable for which you wanted to see the output.
   e.g-> "${lookup(var.ami,var.aws_region)}"


How to allign all the file in a correct format.
syntax-> terraform fmt

What is terraform.tf state?
It is jason file and the current state file. When we run terraform apply command, it matches the local file with the terraform remote file/state. If it is matching , it doesnt go for reprovisioned. But f it dont match it create new resource. Here terraform maintains the resource state which is provisioned by Terraform.

To delete particular resource from your terraform created resource.
Just comment that resource and run again terraform script


What is terraform import?
Terraform import is a command which use to import the resource in your script which is created by manually or when you want your manual created resource to be controlled by terraform.
Steps:
1. first declare the resource. You need to declare it like other resource.
2. Run the import command
    terraform import resourcetype.Logical_name resource_Id
3. Run terraform plan
   To chexk everythings run fine.

How to deal with output?

When you want to see the output of your created resource.
e.g-> output "ip" {
        value = "${resource_type.logical_name.public_ip}"
      }
How to take list of resources as variable ?

Variable.tf file

1. variable "subnets_cidr" {
     type="List"
     default=["10.20.1.0/24",10.20.2.0/24"]
   }
2. In terraform variable will be used as.
   resource "aws_instance" "my" {
     count = "${length(var.subnets_cidr)}"
     ami = "${elements(var.subnets_cidr,count.index)}"
   }

To get list  of all the subnets or instances id or etc, we can use this command
"{$(resource_name.logical_name.*.id)}"

To use ternary operator:

main.tf file will be,
resource "azurerm_network_security_group" "example" {
  count = "${(var.workspace == "dev" ? 1:0)}" #this is the condition line if the variable named workspace has not the value dev, it will not create the resource.
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
}

============================================================================================

HOW TO DO:

1. launched a linux server
2. installed and configured terraform in it.
3. write a script for ec2
   mkdir ec2
   cd ec2
   vi ec2.tf
4. terraform init => It will download all the configuration(cloud providers) realted to the aws cloud.
5. terraform plan => It will show you all the resource which is going to be created.
6. terraform apply => It will create the resources according toyour script.
7. terraform show => to retrive all the details.


State File:

It will save te all details realted to your script.


============================================================================================
HOW TO INSTALL TERRAFORM :

SSH into your cloud server
sudo yum install -y zip unzip (if these are not installed)
wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
unzip terraform_0.12.20_linux_amd64.zip
sudo mv terraform /usr/local/bin/
export PATH="$PATH:/path/to/dir"
example: export PATH="$PATH:/usr/local/bin/"
Confirm terraform binary is accessible: terraform --version

or,
echo $"export PATH=\$PATH:$(pwd)" >> ~/.bash_profile
source ~/.bash_profile


============================================================================================
What is Terraform loop.
Using Terraform loop we can create same multiple resource  dynamically.
1. Create a varaible type list
  
  variable "azs" {
     type="list"
     default=["us-east-1a","us-east1b"]
   }
  variable "subnet_cidr" {
     type="list"
     default=["10.20.1.0/24",10.20.2.0/24"]
   }
In terraform variable will be used as.
   resource "aws_subnets" "my" {
     count="{length(var.azs)}"
     cidr_block = "${elements(var.subnets_cidr,count.index)}"
     tags {
       Name = "Subnets-${count.index+1}"
   }

Data Availablity:

1. Terraform provide ,based on Region we can get data dynamically.

2. To declare data
   data "resource_type" "logical_name" {} #this could be done in variable file or Terrform file
   e.g-> data "aws_availability_zones" "my"{}

3. In terraform you need to write,
   data.resource_type.logical_name.attribute
   
   resource "aws_subnets" "my" {
     count="{length(data.aws_availability_zones.my.names)}"
     cidr_block = "${elements(var.subnet_cidr,count.index)}"
     tags {
       Name = "Subnets-${count.index+1}"
   }
The issue with this terraform file is that it will crate 3 subnet in the same availability zone. To create it in different zone we can modify the script like below.
   
   resource "aws_subnets" "my" {
     count="{length(data.aws_availability_zones.my.names)}"
     availability_zone = "${element(data.aws_availability_zones.my.names,count.index)}"
     cidr_block = "${elements(var.subnet_cidr,count.index)}"
     tags {
       Name = "Subnets-${count.index+1}"
   }


To store Terraform State File in s3 Bucket:

terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}

#This is useful when multiple developer are working on same file.

Locking Remote State File using Dynamdb:
It is useful to lock the state file while modifyng the state file to avaoid concurrency or the changes made by other developers.How to do it ?

1. Create a dynamodb
2. Modify the code,

   terraform {
     backend "s3" {
       bucket = "mybucket"
       key    = "path/to/my/key"
       region = "us-east-1"
       dynamodb = tablename
     }
3. terraform init

#Now, if any developer will try to run the terraform apply command, he wont be able to do it.

  }


============================================================================================
MODULES:

1. Create the folder structure named as modules. Create folder named as environment (like Dev,Prod).
2. Under modules directory create your modules directory like ec2, s3, vpc etc.
3. Lets create module vpc and ec2 .
4. Lets create a networking.tf and variable.tf under vpc module.
5. Lets create a instance.tf and variable.tf under ec2 module.

After creating the modules, lets see how can we use this in different environment.

1. Lets take Dev enviroment first, so create a main.tf file under Dev directory.

main.tf
module "my_vpc" {
  source = "../modules/vpc"
  vpc_cidr = "192.168.0.0/16"
  tenancy = "default"
  vpc_id = "${module.my_vpc.vpc_id}"
  subnet_cidr = "192.168.1.0/24"
  }  
#module_name could be anything
So here we are giving the details according to our wish and all this deatils/variables are mentioned in our networking.tf file but as we know, vpc_id is somewhat which will be created by networking.tf file, so we can not put the value of that according to us. So to resolve this issue, we have got something like output, which we need to mention in our networking.tf file.
output "vpc_id" {
  value = "${aws_vpc.logical_name.id}"
  }
and we need to add use this output in our main.tf file of Dev module as shown above. 
Now we will add instances in main.tf file of Dev Module.

module "my_ec2" {
  source = "../modules/ec2"
  ec2_count =1
  instance_type= "t2.micro"
  subnet_id = "${module.my_vpc.subnet_id}"
  } 

Similarly, we have got the subnet id over here, which we cant give as input by us. So we need to again add output variable of subnet in networking.tf file. And needto use that output here above as the value of subnet_id.
output "subnet_id" {
  value = ${"aws_subnet.logical_name.id"}
  }
