# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated CI/CD of the analysis tasks.

## 🔄 Available Workflows

### 1. Build and Deploy (`build-and-deploy.yml`)

**Trigger**: Push to `main` or `develop` branches, Pull Requests to `main`

**What it does**:
- Runs tests and linting
- Builds Docker images for all three analysis types
- Pushes images to Amazon ECR
- Registers ECS task definitions
- Creates CloudWatch log groups

**Required Secrets**:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`

### 2. Run Analysis (`run-analysis.yml`)

**Trigger**: Manual workflow dispatch

**What it does**:
- Allows manual triggering of analysis tasks
- Supports all three analysis types (framework, surface, demographics)
- Configurable cluster and network settings

**Parameters**:
- `analysis_type`: Type of analysis to run (framework/surface/demographics)
- `cluster_name`: ECS cluster name
- `subnet_ids`: Comma-separated subnet IDs
- `security_group_ids`: Comma-separated security group IDs

## 🚀 Usage

### Automatic Deployment

1. Push code to `main` branch
2. Workflow automatically:
   - Runs tests
   - Builds and pushes Docker images
   - Updates ECS task definitions
   - Creates necessary AWS resources

### Manual Analysis Execution

1. Go to GitHub Actions tab
2. Select "Run Analysis Tasks" workflow
3. Click "Run workflow"
4. Fill in the parameters:
   - Analysis type
   - Cluster name
   - Network configuration
5. Click "Run workflow"

## Configuration

### Environment Variables

The workflows use the following environment variables:

```yaml
env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com
```

### Required GitHub Secrets

Set these in your repository settings under "Secrets and variables" → "Actions":

| Secret | Description | Required |
|--------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | Yes |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | Yes |
| `AWS_ACCOUNT_ID` | AWS Account ID | Yes |

### IAM Permissions

The AWS credentials need the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "ecs:*",
        "logs:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

## 📊 Workflow Status

### Build and Deploy Workflow

1. **Test Job**: Runs linting, type checking, and tests
2. **Build and Push Job**: Builds Docker images and pushes to ECR
3. **Deploy Job**: Registers task definitions and creates log groups

### Run Analysis Workflow

1. **Run Analysis Job**: Executes the specified analysis task on ECS

## 🔍 Monitoring

### Workflow Logs

- View workflow execution in GitHub Actions tab
- Check individual job logs for detailed information
- Monitor ECS task execution in AWS Console

### CloudWatch Integration

- All tasks log to CloudWatch log groups
- Log groups are automatically created during deployment
- Log groups: `/ecs/framework-analysis`, `/ecs/surface-analysis`, `/ecs/demographics-analysis`

## 🛠️ Troubleshooting

### Common Issues

1. **Workflow fails at test stage**
   - Check code quality issues
   - Fix linting errors
   - Update dependencies

2. **Build fails**
   - Verify Dockerfile syntax
   - Check for missing files
   - Ensure requirements.txt is up to date

3. **Deployment fails**
   - Verify AWS credentials
   - Check IAM permissions
   - Ensure ECS cluster exists

4. **Task execution fails**
   - Check CloudWatch logs
   - Verify secrets in AWS Secrets Manager
   - Check network configuration

### Debug Commands

```bash
# Check workflow status
gh run list --workflow=build-and-deploy.yml

# View workflow logs
gh run view RUN_ID --log

# Check ECS task status
aws ecs list-tasks --cluster analysis-cluster
```

## 📝 Notes

- Workflows are designed for Fargate deployment
- Images are tagged with both commit SHA and `latest`
- Task definitions are updated on every deployment
- CloudWatch log groups are created automatically
- All workflows include proper error handling and notifications
