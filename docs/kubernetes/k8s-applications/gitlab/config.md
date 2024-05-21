---
tags:
  - gitlab
---

# 配置

## 对接oauth

#### 1. sso创建应用

账号主体选择openid，scope勾选授权码认证的openid和profile

#### 2. 配置gitlab，修改配置文件gitlab.rb

- [omniauth配置说明](https://docs.gitlab.com/ee/integration/omniauth.html)

- [oauth2配置说明](https://docs.gitlab.com/ee/integration/oauth2_generic.html)

```rb

# 认证对接配置
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_block_auto_created_users'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['oauth2_generic']
gitlab_rails['omniauth_external_providers'] = ['oauth2_generic','openid_connect']
gitlab_rails['omniauth_providers'] = [
  {
    name: "oauth2_generic",
    label: "Login with xxxxx", # optional label for login button, defaults to "Oauth2 Generic"
    app_id: "<your_app_client_id>",
    app_secret: "<your_app_client_secret>",
    args: {
      client_options: {
        site: "https://oauth.site",
        user_info_url: "/sso/oauth2/userinfo",
        authorize_url: "/sso/oauth2/authorize",
        token_url: "/sso/oauth2/token"
      },
      user_response_structure: {
        root_path: [],
        id_path: ["sub"],
        attributes: {
          name: "name",
          nickname: "userName",
          email: "email"
        }
      },
      authorize_params: {
        scope: "openid profile"
      },
      strategy_class: "OmniAuth::Strategies::OAuth2Generic"
    }
  }
]


```
