# Social Media Integration

## Table of Contents

- [Facebook](#facebook)
  - [Facebook Access Token](#facebook-access-token)
  - [Facebook API Paths](#facebook-api-paths)
  - [Facebook Tools](#facebook-tools)

## Facebook

Our App is using [koala](https://github.com/arsduo/koala) gem to handle requests to Facebook API

### Facebook Access Token

In Facebook there's two types of access token. Short-lived and Long-lived Access Token, so instead of separate token like other integration that using access token and refresh token, Facebook using one token that can be exchange to another token to updating the expiry time.

- Short-lived Access Token expiry time is an hour
  > Default User and Page access tokens are short-lived, expiring in hours, however, you can exchange a short-lived token for a long-lived token.
  >
  > source: https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived
- Long-lived Access Token expiry time is 60 days
  > If you need a long-lived User access token you can generate one from a short-lived User access token. A long-lived token generally lasts about 60 days.
  >
  > source: https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived

We are saving access token into WlCompany and SiteInfo models.

- WlCompany usage is for getting Instagram followers count
- SiteInfo usage is for getting Facebook page or Instagram account info, posts and insights

### Facebook API Paths

These are the list of paths that we are using in our app

- /me/accounts - Get all pages and instagram account that the user has access to https://developers.facebook.com/docs/graph-api/reference/user/accounts/
- /{page-id}/ - Get page info https://developers.facebook.com/docs/graph-api/reference/page/
- /{page-id}/feed - Get page posts https://developers.facebook.com/docs/graph-api/reference/page/feed/
- /{page-id}/insights - Get page insights https://developers.facebook.com/docs/graph-api/reference/page/insights/'
- /{ig-user-id} - Get instagram account info https://developers.facebook.com/docs/graph-api/reference/ig-user/
- /{ig-user-id}/media - Get instagram account posts https://developers.facebook.com/docs/graph-api/reference/ig-user/media/
- /{ig-user-id}/insights - Get instagram account insights https://developers.facebook.com/docs/graph-api/reference/ig-user/insights/

### Facebook Tools

- [Facebook Graph API Explorer](https://developers.facebook.com/tools/explorer/)
- [Facebook Access Token Debugger](https://developers.facebook.com/tools/debug/accesstoken/)
