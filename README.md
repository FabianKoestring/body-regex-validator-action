# issue-guideline-checker
This Action checks issue and pull-request descriptions against an regular expression. This can be used to check if the description met your Github template files.

## Usage
This Action subscribes to [Pull request events](https://developer.github.com/v3/activity/events/types/#pullrequestevent) and [Issues events](https://developer.github.com/v3/activity/events/types/#issuesevent) which will fire whenever Issues or Pull requests get created.

```workflow
name: Issue guideline checker
on: [issues, pull_request]
jobs:
  guidelinechecker:
    name: Guideline checker
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Project
      uses: actions/checkout@v1
      with:
        fetch-depth: 1
    - name: Run guideline checker
      uses: fabiankoestring/issue-guideline-checker@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        PULL_REQUEST_PATTERN: '^(.*Description.*Changes.*Tests.*)$'
        PULL_REQUEST_COMMENT: 'This is my pr comment template.'
        ISSUE_PATTERN: '^(.*Description.*Behavior.*)$'
        ISSUE_COMMENT: 'This is my issue comment template.'
```
## Demo


## License
The Dockerfile and associated scripts and documentation in this project are released under the [GNU General Public License v3.0](LICENSE).
