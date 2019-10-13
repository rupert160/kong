# KONG using Terraform, AWS CodePipelines and Fargate for ECS
This code uses Terraform to provision AWS resources,

## Primarily using:
https://github.com/kylegalbraith/aws-ecr-codepipeline-demo.git
as a basis for AWS Code Pipelines to Build and Host the Container Image in ECR

https://github.com/cn-terraform/terraform-aws-ecs-fargate.git
as a basis for AWS Fargate initialisation and Kong image deployment

You are required to make "enable the new ARN and resource ID format" here:
https://ap-southeast-2.console.aws.amazon.com/ecs/home?region=ap-southeast-2#/settings
https://aws.amazon.com/ecs/faqs/#Transition_to_new_ARN_and_ID_format

You also need to instal SSH keys for your IAM user and configure your ~/.ssh/config
file to link your IAM user to CodeCommit repos in AWS
https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html

The bash scripts require .aws/{config,credentials} files and the default profile to be used.
This is a bit of a RISK so please be mindful of this setup

Actual codebase changed can be computed from reference to:
git tag --annotate floss-pipeline 591f06c
git tag --annotate floss-fargate e57be74

which are the last Git SHA's for the respective open source projects utilized.

Improvements to be made:
Given the two different ways this project uses AWS credentials, due to the reference implementation
aligning these methods (using files vs using "AWS" vars) would be preferred.

the code build is asyncronus, hence presently the build has a 
broken step whist the user manually checks for a successful build before fargate is deployed.
hence a terraform "depends_on" operator would ideally connect this. Presently not done.
A simple way could be to "poll" the outcome.

The initialisation function is not completely Idempotent so presently it must only get run once.
function choice is presently a case of uncommenting the code you wish to run.
needs to be cleaned up for better UX.
