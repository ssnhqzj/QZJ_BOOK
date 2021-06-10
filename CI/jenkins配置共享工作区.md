1. 安装插件Shared workspace

2. 参考了官方文档的使用说明
```
How to use it:

1) In "Manage Jenkins"->"Configure System" find new "Workspace Sharing" block.

2) Add some Name + SCM Repo URL pairs. Save.

3) Go to the job configuration page, now you able to select "Shared Workspace" here.

4) Use ${SHAREDSPACE_SCM_URL} variable in your SCM url field.

Workspaces will be created as {node remote FS root}/sharedspace/{workspace name}
```