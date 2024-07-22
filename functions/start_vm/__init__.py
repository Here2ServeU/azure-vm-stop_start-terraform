import os
import logging
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.monitor import MonitorManagementClient
from azure.mgmt.monitor.models import EmailReceiver, ActionGroupResource

def main(mytimer: func.TimerRequest) -> None:
    vm_ids = os.environ['VM_IDS'].split(',')
    subscription_id = os.environ['AZURE_SUBSCRIPTION_ID']
    resource_group = os.environ['RESOURCE_GROUP']
    monitor_client = MonitorManagementClient(DefaultAzureCredential(), subscription_id)
    compute_client = ComputeManagementClient(DefaultAzureCredential(), subscription_id)
    
    for vm_id in vm_ids:
        compute_client.virtual_machines.begin_start(resource_group, vm_id)
        logging.info(f'Successfully started VM: {vm_id}')
    
    email_receiver = EmailReceiver(
        email_address="your-email@example.com",
        name="VM Start Notification"
    )
    
    action_group = ActionGroupResource(
        location="Global",
        group_short_name="vm_start_ag",
        enabled=True,
        email_receivers=[email_receiver]
    )
    
    monitor_client.action_groups.create_or_update(
        resource_group_name=resource_group,
        action_group_name="vm_start_action_group",
        action_group=action_group
    )
    
    logging.info("VM start notifications setup complete.")
