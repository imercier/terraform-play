# terraform-neptune
A very simple AWS Neptune terraform plan with ec2 used as a ssh tunnel gateway

## Overview

This terraform creates:
* a new vpc
* two subnets, each in a different availability zone, needed by neptune
* a ec2, to tunnelize neptune websocket connection to local port, through aws internet gateway
* output indicating ssh tunneling and neptune endpoint


## To deploy infrastructure:
```bash
export AWS_DEFAULT_REGION=$(aws configure get region --profile default)
terraform init
terraform plan
terraform apply -auto-approve

terraform destroy -auto-approve
```

## To install gremlin console:

https://docs.aws.amazon.com/neptune/latest/userguide/access-graph-gremlin-console.html


apache-tinkerpop-gremlin-console-3.4.10/conf/neptune-remote.yaml
```yaml
hosts: [localhost]
port: 8182
connectionPool: { enableSsl: true,  trustStore: /tmp/certs/cacerts }
serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { serializeResultToString: true }}
```
