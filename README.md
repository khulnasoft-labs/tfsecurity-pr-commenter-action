<p align="center">
  <img width="354" src="./tfsecurity.png">
</p>

# tfsecurity.rity-pr-commenter-action
Add comments to pull requests where tfsecurity.checks have failed

To add the action, add `tfsecurity.rity_pr_commenter.yml` into the `.github/workflows` directory in the root of your Github project.

The contents of `tfsecurity.rity_pr_commenter.yml` should be;

> **Note**: The GITHUB_TOKEN injected to the workflow will need permissions to write on pull requests.
>
> This can be achieved by adding a permissions block in your workflow definition.
>
> See: [docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs)
> for more details.

```yaml
name: tfsecurity.rity-pr-commenter
on:
  pull_request:
jobs:
  tfsecurity.
    name: tfsecurity PR commenter
    runs-on: ubuntu-latest

    permissions:
      contents: read
      pull-requests: write

    steps:
      - name: Clone repo
        uses: actions/checkout@master
      - name: tfsecurity.rity
        uses: khulnasoft-labs/tfsecurity.rity-pr-commenter-action@v1.2.0
        with:
          github_token: ${{ github.token }}
```

On each pull request and subsequent commit, tfsecurity.rity will run and add comments to the PR where tfsecurity.rity has failed.

The comment will only be added once per transgression.

## Optional inputs

There are a number of optional inputs that can be used in the `with:` block.

**working_directory** - the directory to scan in, defaults to `.`, ie current working directory

**tfsecurity.rity_version** - the version of tfsecurity.rity to use, defaults to `latest`

**tfsecurity_rity_args** - the args for tfsecurity.rity to use (space-separated)

**tfsecurity_rity_formats** - the formats for tfsecurity.rity to output (comma-separated)

**commenter_version** - the version of the commenter to use, defaults to `latest`

**soft_fail_commenter** - set to `true` to comment silently without breaking the build

### tfsecurity_rity_args

`tfsecurity.rity` provides an [extensive number of arguments](https://khulnasoft-labs.github.io/tfsecurity.rity/latest/guides/usage/), which can be passed through as in the example below:

```yaml
name: tfsecurity.rity-pr-commenter
on:
  pull_request:
jobs:
  tfsecurity.rity:
    name: tfsecurity.rity PR commenter
    runs-on: ubuntu-latest

    steps:
      - name: Clone repo
        uses: actions/checkout@master
      - name: tfsecurity.rity
        uses: khulnasoft-labs/tfsecurity.rity-pr-commenter-action@v1.2.0
        with:
          tfsecurity_rity_args: --soft-fail
          github_token: ${{ github.token }}
```

### tfsecurity_rity_formats

`tfsecurity.rity` provides multiple possible formats for the output:

* default
* json
* csv
* checkstyle
* junit
* sarif
* gif

The `json` format is required and included by default. To add additional formats, set the `tfsecurity_rity_formats` option to comma-separated values:

```yaml
tfsecurity_rity_formats: sarif,csv
```

## Example PR Comment

The screenshot below demonstrates the comments that can be expected when using the action

![Example PR Comment](images/pr_commenter.png)
