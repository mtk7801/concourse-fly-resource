Concourse Fly Resource
======================

A [Concourse](https://concourse-ci.org/) resource for executing `fly` and fetching its output. Based on https://github.com/troykinsella/concourse-fly-resource.

## Resource Type Configuration

```yaml
resource_types:
- name: fly-restype
  type: docker-image
  source:
    repository: mtk7801/concourse-fly-resource
    tag: 0.5
```

## Source Configuration

Currently only HTTP basic authentication is supported.

* `url`: _Optional_. The base URL of the concourse instance to contact (https://ci.concourse-ci.org).
  Default: The value of the `$ATC_EXTERNAL_URL` [metadata](https://concourse-ci.org/implementing-resource-types.html#resource-metadata) variable.
* `username`: _Required_. The concourse basic auth username.
* `password`: _Required_. The concourse basic auth password.
* `target`: _Optional_. The name of the target concourse instance. Default: "main".
* `team`: _Optional_. The concourse team to login to. Default: The value of the
  `$BUILD_TEAM_NAME` [metadata](https://concourse-ci.org/implementing-resource-types.html#resource-metadata) variable.
* `insecure`: _Optional_. Set to `true` to skip TLS verification.
* `debug`: _Optional_. Set to `true` to print commands (such as `fly login` and `fly sync`) for troubleshooting, including credentials. Default: `false`.
* `secure_output`: _Optional_. Set to `false` to show potentially insecure options and echoed fly commands. Default: `true`.
* `multiline_lines`: _Optional_. Set to `true` to interpret `\` as one line (mostly for big options line).

### Example

```yaml
resources:
- name: fly-res
  type: fly-restype
  source:
    url: {{concourse_url}}
    username: ((concourse_username))
    password: ((concourse_password))
    team: dev-team
```

## Behaviour

### `check`: No-Op

### `in`: Execute `fly` command

Execute the given `fly` command along with given options. The `fly` client is downloaded from the target 
Concourse instance if not already present. If there is a version mismatch between `fly` and Concourse,
a `fly sync` is performed.
When multiple lines are present in the provided options, `fly` is executed separately for each line.
Output from the `fly` execution(s) is appended to fly_output.txt

#### Parameters

* `options`: _Optional_. The options to pass to `fly`.
* `options_file`: _Optional_. A file containing options to pass to `fly`.

Parameters are passed through to the `fly` command as follows:
```sh
fly -t <target> <options>
```

Concourse [metadata](https://concourse-ci.org/implementing-resource-types.html#resource-metadata)
variables are supported in options.

### `out`: Report the build number, so that `in` can run.

#### Example

```yaml
jobs:
- name: print-pipelines-info
  plan:
    - put: fly-res
      get_params:
        options: pipelines --json
    - task: print-pipelines-info-as-json
      config:
        platform: linux
        image_resource:
          type: docker-image
          source: { repository: busybox }
        inputs:
          - name: fly-res
        run:
          path: /bin/sh
          args:
          - -c
          - |-
            cat fly-res/fly_output.txt
```
