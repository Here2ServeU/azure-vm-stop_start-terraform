# Automating Azure VM Management with Scheduled Start and Stop using Logic Apps and Functions

## Introduction:
* 👋 Hey everyone! Welcome back to my GitHub.
* 🎥 This repo shows you how to schedule times to start and stop your Vitural Machines.
* 📊 The tools we use for this infrastructure include: ***Logic Apps Workflows***, ***Function App Execution***, ***Email Notifications***, ***IAM***, and ***Terraform***. 

## Prerequisites:
* Terraform installed on your local Machine.
* An Account with Azure.
* Azure CLI.

## Steps:
**1. Clone this Repo to your local machine:**
* git clone https://github.com/azure-vm-stop_start-terraform

**2. Define the input variables:**
* Go to the terraform.tfvars file and change the variables as desired. 

**3. Initialize, Plan, and Apply the Terraform Configurations.**  
* terraform init
* terraform plan
* terraform apply

**4. Clean up**
* terraform destroy

## Troubleshooting:
**Logic Apps Workflows**: Verify that the Logic Apps workflows are correctly created in the Azure Portal under Logic Apps. Ensure the schedules and HTTP request URLs are correct.

**Function App Execution**: Check the logs for the Function Apps in the Azure Portal to see if they are being invoked correctly and if there are any errors during execution.

**Email Notifications**: Ensure that the email notifications are being sent correctly. Check the action groups in Azure Monitor for any issues.

**IAM Role Permissions**: Ensure the IAM role attached to the Function Apps has the correct permissions to start and stop VMs, as well as send notifications via Azure Monitor.

## Outro:
* 🎉 Congrats! You have successfully set up an infrastructure that will automatically start and stop your Virtual Machines using Terraform.
* 💬 Leave any questions or comments below; I'll be happy to help!
