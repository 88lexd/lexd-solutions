from kubernetes import client, config
import kubernetes.client
import debugpy

debugpy.listen(5678)
debugpy.wait_for_client()
debugpy.breakpoint()