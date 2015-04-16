# dockerdeploy-cookbook

This is an example cookbook to show how to deploy a docker container from a
private registry to a linux machine.  

It's using a private docker repository, but you can switch to use anyone, see
docker cookbook for details.

This example is also showing how to specify a tag for which docker container
to run.

## Supported Platforms

Tested on ubuntu, but should work with any platform the docker cookbook supports

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['dockerdeploy']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### dockerdeploy::default

Include `dockerdeploy` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[dockerdeploy::default]"
  ]
}
```

## License and Authors

Author:: Jim Castillo (<YOUR_EMAIL>)
