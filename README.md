# Newsela Exercise
## Purpose
This repository's purpose is to provide a solution to Newsela's home coding exercise.  The requirements are:

    Write a Terraform module for generating the infrastructure needed for hosting a static website/app on AWS.
    
    The code should include resources for:
    
    -   Storing the static site content
    -   Serving the content with a CDN
    -   Providing hosted zone and cname for the site
    
    The solution should support:
    
    -   Creating multiple separate environments - E.g. make it easy to deploy to new environments without manual work in AWS UI
    -   Reuse without changing/removing hard-coded strings within the resource blocks
    -   Providing inputs/outputs so that the code could be invoked from a CI or other system
    
    Extra credit for...
    
    -   Cloudwatch resources to help monitor the site
    -   WAF for providing additional security capabilities
    -   Log delivery to S3/Athena for downstream analysis
    -   Integration (even partial) with any of the AWS Code* CI/CD tools


## Assumptions
This assumes that you have:

 - Sufficient access to an existing AWS with existing keys or tokens
   already configured on the command-line 
- A registered domain-name with
   AWS (e.g. newsela.com) in the account
- An existing AWS wildcard
   certificate configured for domain in AWS Certificate Manager (e.g.
   *.newsela.com) 
- 'Website' is a unique S3 name
- Terraform v1.1.7

## Outputs
Outputs this repository will provide:

### S3 buckets in the format (for example):
- website (prod -- content bucket)
- website-logging (prod logging access bucket)
- website-ENV (Non-prod environments if required -- content bucket)
- website-ENV-logging (Non-prod environments if required -- logging bucket)

### CloudFront distributions:
- Production distribution with CNAME alias to website (e.g. website.newsela.com)
- Non-production distribution with CNAME alias to website.ENV (e.g. website-ENV.newsela.com)
- WAF protected

### CNAMEs:
CNAME entries in shared zone (e.g. website.newsela.com, website-ENV.newsela.com)

### WAFs:
Web ACL to protect each distribution
## Usage

If you need to create the base zone shared by environments, you can create it by running from the repo's root dir:

    cd shared 
    vim terraform.tfvars [edit base zone/DNS name]
    terraform init
    terraform plan
    terraform apply

Once hosted-zone is created, cd back to the repo base directory (substitute ENV for 'prod', 'qa' or 'dev'):

     1. cd stack 
     2. vim main.tf
	     edit:
	     - base_website_name (e.g. 'website' for website.newsela.com)
	     - zone (e.g. newsela.com')
	     - cert_arn for wildcard cert in us-east-1 (e.g. ARN for *.newselsa.com) 
     3. terraform workspace create ENV 
     4. vim ENV.tfvars [edit for region] 
     5. terraform init -var-file=ENV.tfvars 
     6. terraform plan -var file=ENV.tfvars 
     7. terraform apply -var file=ENV.tfvars

Repeat 3-7 for each ENV.

## Automation

Automation via CI/CD pipeline can be achieved by referencing appropriate workspaces ('prod', 'dev', etc) and ENV.tfvars files via passing command-line arguments above or leveraging environment variables.

## Improvements

If I had more time, the following improvements are what I would do/consider:
 - Base 'website' name need not equate to S3 bucket names.  I'd likely refactor
   the end-product S3 buckets to be website[-env].zone.com for the bucket names.  E.g.
   website.newsela.com (prod), website-dev.newsela.com (dev), etc.  (Instead of just 'website-dev')  This would prevent the likelihood that there would be a bucket-name
   collision within AWS and provides clarity to what the bucket actually is
- Configure Terraform backends so as not use local state-files, but instead use a versioned S3 bucket and use state-file locking to prevent conflicts
- Consider locking module in stack/main.tf to tagged version in GitHub
- Configure the WAF to be more robust.  The WAF configuration here is an example to build from
- Configure CloudWatch monitoring
- Cloudfront distribution configuration is boiler-plate.  It should be tweaked to suit needs
- More comments in code and better documentation

