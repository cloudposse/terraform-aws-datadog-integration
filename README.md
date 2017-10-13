# terraform-datadog-aws-integration
Terraform Module for integration DataDog with AWS



## Usage
**Note:** At the moment the module supports `RDS integration only`. It will be modified as necessary to integrate the needful services.

Include this module in your existing terraform code:

```hcl
module "datadog_aws_integration" {
  source = "git::https://github.com/cloudposse/terraform-datadog-aws-integration.git?ref=master"
  namespace                  = "${var.namespace}"
  name                       = "${var.name}"
  stage                      = "${var.stage}"
  datadog_external_id        = "dfae1fe3434..."
  integrations               = ["RDS", "S3", ...]
}
```

## Variables

| Name                           | Default          | Description                                                                              | Required   |
| :----------------------------- | :--------------: | :--------------------------------------------------------                                | :--------: |
| namespace                      | ``               | Namespace (e.g. `cp` or `cloudposse`)                                                    | Yes        |
| stage                          | ``               | Stage (e.g. `prod`, `dev`, `staging`)                                                    | Yes        |
| name                           | ``               | Name  (e.g. `bastion` or `db`)                                                           | Yes        |
| attributes                     | []               | Additional attributes (e.g. `policy` or `role`)                                          | No         |
| tags                           | {}               | Additional tags  (e.g. `map("BusinessUnit","XYZ")`                                       | No         |
| datadog_external_id            | ``               | External Id of the DataDog service                                                       | Yes        |
| datadog_aws_account_id         | `464622532012`   | Datadog’s AWS account ID                                                                 | No         |
| integrations                   | []               | List of AWS Services to integration with the DataDog service (e.g EC2, RDS, Billing ...) | Yes        |

## Outputs

| Name                | Decription                                                        |
|:--------------------|:------------------------------------------------------------------|
| `role`              | Name of AWS IAM Role associated with creating integration         |

## Help

**Got a question?**

Review the [docs](docs/), file a GitHub [issue](https://github.com/cloudposse/terraform-datadog-aws-integration/issues), send us an [email](mailto:hello@cloudposse.com) or reach out to us on [Gitter](https://gitter.im/cloudposse/).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-datadog-aws-integration/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing Geodesic, we would love to hear from you! Shoot us an [email](mailto:hello@cloudposse.com).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

**NOTE:** Be sure to merge the latest from "upstream" before making a pull request!

## License

[APACHE 2.0](LICENSE) © 2016-2017 [Cloud Posse, LLC](https://cloudposse.com)

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## About

This module is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know at <hello@cloudposse.com>

We love [Open Source Software](https://github.com/cloudposse/)!

See [our other projects][community]
or [hire us][hire] to help build your next cloud-platform.

  [website]: http://cloudposse.com/
  [community]: https://github.com/cloudposse/
  [hire]: http://cloudposse.com/contact/

### Contributors

| [![Erik Osterman][erik_img]][erik_web]<br/>[Erik Osterman][erik_web]        | [![Igor Rodionov][igor_img]][igor_web]<br/>[Igor Rodionov][igor_web] | [![Andriy Knysh][andriy_img]][andriy_web]<br/>[Andriy Knysh][andriy_web]  | [![Sergey Vasilyev][sergey_img]][sergey_web]<br/>[Sergey Vasilyev][sergey_web] | [![Konstantin B][konstantin_img]][konstantin_web]<br/>[Konstantin B][konstantin_web] | [![Valeriy][valeriy_img]][valeriy_web]<br/>[Valeriy][valeriy_web]      | [![Vladimir][vladimir_img]][vladimir_web]<br/>[Vladimir][vladimir_web] |
|---------------------------------------------------------------------------- | ------------------------------------------------------------------   | ------------------------------------------------------------------------- | ----------------------------------------------------------------------         | ----------------------------------------------------------------------               | ---------------------------------------------------------------------- | -----------------------------------------------------------------------|

  [erik_img]: http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144
  [erik_web]: https://github.com/osterman/
  [igor_img]: http://s.gravatar.com/avatar/bc70834d32ed4517568a1feb0b9be7e2?s=144
  [igor_web]: https://github.com/goruha/
  [andriy_img]: https://avatars0.githubusercontent.com/u/7356997?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
  [andriy_web]: https://github.com/aknysh/
  [sergey_img]: https://avatars1.githubusercontent.com/u/1134449?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
  [sergey_web]: https://github.com/s2504s/
  [konstantin_img]: https://avatars1.githubusercontent.com/u/11299538?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
  [konstantin_web]: https://github.com/comeanother/
  [valeriy_img]: https://avatars1.githubusercontent.com/u/10601658?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
  [valeriy_web]: https://github.com/drama17/
  [vladimir_img]: https://avatars1.githubusercontent.com/u/26582191?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
  [vladimir_web]: https://github.com/SweetOps/
