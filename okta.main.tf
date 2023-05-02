variable "base_url" {
  description = "The Okta base URL. Example: okta.com, oktapreview.com, etc. This is the domain part of your Okta org URL"
}
variable "org_name" {
  description = "The Okta org name. This is the part before the domain in your Okta org URL"
}
variable "api_token" {
  type        = string
  description = "The Okta API token, this will be read from environment variable (TF_VAR_api_token) for security"
  sensitive   = true
}


# Enable and configure the Okta provider
terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 3.15"
    }
  }
}

provider "okta" {
  org_name  = var.org_name
  base_url  = var.base_url
  api_token = var.api_token
}

#*************************************Creat Okta users and groups and assign users to groups*******************

#*********************Cluster admins (k8s-admins) and users************************
resource "okta_user" "admin" {
  first_name = "admin"
  last_name = "admin"
  email = "admin@acme.com"
  login = "admin@acme.com"
  password = "P@ssw0rd1!"
  status = "ACTIVE"
}

resource "okta_group" "k8s-admin" {
  name = "k8s-admin"
}

resource "okta_user_group_memberships" "admin_k8s-admin" {
  user_id = okta_user.admin.id
  groups = [
    okta_group.k8s-admin.id
  ]
}

#********************************************************************************

#*********************Creat k8s-marketing-admins group and members************************
resource "okta_user" "jane_doe" {
  first_name = "jane"
  last_name = "doe"
  email = "jane.doe@acme.com"
  login = "jane.doe@acme.com"
  password = "P@ssw0rd2!"
  status = "ACTIVE"
}

resource "okta_group" "k8s-marketing-admins" {
  name = "k8s-marketing-admins"
}

resource "okta_user_group_memberships" "jane_doe_k8s-marketing-admins" {
  user_id = okta_user.jane_doe.id
   groups = [
    okta_group.k8s-marketing-admins.id
  ]   
}
#********************************************************************************

#*********************Creat k8s-marketing-dev-ops group and members************************
resource "okta_user" "john_doe" {
  first_name = "john"
  last_name = "doe"
  email = "john.doe@acme.com"
  login = "john.doe@acme.com"
  password = "P@ssw0rd2!"
  status = "ACTIVE"
}

resource "okta_group" "k8s-marketing-dev-ops" {
  name = "k8s-marketing-dev-ops"
}

resource "okta_user_group_memberships" "john_doe_k8s-marketing-dev-ops" { 
  user_id = okta_user.john_doe.id
  groups = [
    okta_group.k8s-marketing-dev-ops.id
  ]  
}
#********************************************************************************

#*********************Creat "k8s-marketing-devs group and members************************
resource "okta_user" "terry_jones" {
  first_name = "terry"
  last_name = "jones"
  email = "terry.jones@acme.com"
  login = "terry.jones@acme.com"
  password = "P@ssw0rd3!"
  status = "ACTIVE"
}

resource "okta_group" "k8s-marketing-devs" {
  name = "k8s-marketing-devs"
}

resource "okta_user_group_memberships" "terry_jones_k8s-marketing-devs" {
  user_id = okta_user.terry_jones.id
  groups = [
    okta_group.k8s-marketing-devs.id
  ]  
}
#********************************************************************************
#**************************************************************************************************************

#****************************Create an OIDC application********************************************************

resource "okta_app_oauth" "k8s_oidc" {
  label                      = "k8s OIDC"
  type                       = "native" # this is important
  token_endpoint_auth_method = "none"   # this sets the client authentication to PKCE
  grant_types = [
    "authorization_code"
  ]
  response_types = ["code"]
  redirect_uris = [
    "http://localhost:8000",
  ]
  post_logout_redirect_uris = [
    "http://localhost:8000",
  ]
  
}

# Assign groups to the OIDC application
resource "okta_app_group_assignments" "k8s_oidc_group" {
  app_id = okta_app_oauth.k8s_oidc.id
  group {
    id = okta_group.k8s-admin.id
  }
  group {
    id = okta_group.k8s-marketing-admins.id
  }
group {
    id = okta_group.k8s-marketing-devs.id
  }
group {
    id = okta_group.k8s-marketing-dev-ops.id
  }

}

output "k8s_oidc_client_id" {
  value = okta_app_oauth.k8s_oidc.client_id
}


#****************************Create an authorization server****************************************************


resource "okta_auth_server" "oidc_auth_server" {
  name      = "k8s-auth"
  audiences = ["http:://localhost:8000"]
}

output "k8s_oidc_issuer_url" {
  value = okta_auth_server.oidc_auth_server.issuer
}

# Add claims to the authorization server

resource "okta_auth_server_claim" "auth_claim" {
  name                    = "groups"
  auth_server_id          = okta_auth_server.oidc_auth_server.id
  always_include_in_token = true
  claim_type              = "IDENTITY"
  group_filter_type       = "STARTS_WITH"
  value                   = "k8s-"
  value_type              = "GROUPS"
}

# Add policy and rule to the authorization server

resource "okta_auth_server_policy" "auth_policy" {
  name             = "k8s_policy"
  auth_server_id   = okta_auth_server.oidc_auth_server.id
  description      = "Policy for allowed clients"
  priority         = 1
  client_whitelist = [okta_app_oauth.k8s_oidc.id]
}

resource "okta_auth_server_policy_rule" "auth_policy_rule" {
  name           = "AuthCode + PKCE"
  auth_server_id = okta_auth_server.oidc_auth_server.id
  policy_id      = okta_auth_server_policy.auth_policy.id
  priority       = 1
  grant_type_whitelist = [
    "authorization_code"
  ]
  scope_whitelist = ["*"]
  group_whitelist = ["EVERYONE"]

  
}
