# List of Regex used for validations
REGEX_EMAIL = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
REGEX_URL = %r{^https?://}
REGEX_USERNAME = /^[a-z|A-Z\d_.]+$/i
REGEX_IP_ADDRESS = /\d{1,3}(?:\.\d{1,3}){3}/

##
# Used to determine all HTML attributes that are allowed
# on the content.
# type attribute is used for ol html tag to specify bullet point types
SAFE_HTML_ATTRIBUTES = ['href', 'class', 'target', 'style', 'src', 'type', 'width', 'height', 'title', 'alt']

# TOKENS
TOKEN_DEEPLINKING = '-t-' # token to use for deeplinking
TOKEN_DEEPLINKING_DECODED = '-t_decoded-' # token to use for deeplinking with value decoded
# Token for deeplinking where value is double encoded
TOKEN_DEEPLINKING_DOUBLE_ENCODED = '-t_double_encoded-'

TOKEN_SPLIT = '-split-' # used as delimiter of a set of data that want to be split tested (e.g: for affiliate kvp)

TOKEN_REGEX = /-(\w+)-/ # a regular expression to detect if content has token.
TOKEN_REGEX_AFFILIATE = /-aff_(\w+)-/ # a regular expression to detect the affiliate token.
TOKEN_REGEX_SNIPPET = /-snippet_(\w+)-/ # a regular expression to detect the snippet token.
TOKEN_REGEX_TRANSACTION = /-transaction_(\w+)_*(\(.+\))?-/ # a regular expression to detect the transaction token.

TOKEN_REGEX_ORDER = /-order_(\w+)-/ # a regular expression to detect the order.

TOKEN_SERVER_SUBID = '-server_subid-'
TOKEN_TID = '-tid-' # used to forward our transaction id
TOKEN_EMAIL_VERIFICATION_URL = '-email_verification_url-' # used in email template
TOKEN_AFFILIATE_REGISTRATION_URL = '-affiliate_registration_url-' # to render affiliate registration url on email template.
TOKEN_SITE_NAME = '[-site_name-]'
TOKEN_SOURCE_ID = '-source_id-' # used to pass over source id (such as affiliate id) to Offer's target URL
TOKEN_NO_CAMPAIGN_NAME = '[-no_campaign_name-]'
TOKEN_NO_AD_GROUP_NAME = '[-no_ad_group_name-]'
TOKEN_SUBID_1 = '-subid_1-'
TOKEN_SUBID_2 = '-subid_2-'
TOKEN_SUBID_3 = '-subid_3-'
TOKEN_SUBID_4 = '-subid_4-'
TOKEN_SUBID_5 = '-subid_5-'
TOKEN_GAID = '-transaction_gaid-'
TOKEN_URL_PATTERN_WILDCARD = '-wildcard-'
TOKEN_TRACKING_URL = '-tracking_url-'
TOKEN_SHORT_TRACKING_URL = '-short_tracking_url-'
TOKEN_SOURCE_AFFILIATE_ID = '-source_affiliate_id-' # used to forward original affiliate id info to the other offer(s)
TOKEN_SOURCE_OFFER_ID = '-source_offer_id-' # used to forward original offer id info to the other offer(s)
TOKEN_SOURCE_TID = '-source_tid-'  # used to forward the original transaction id to the other offer(s)
TOKEN_SOURCE_TAG = '-source_tag-'  # used to forward the original tag to the other offer(s)

EXPR_REGEX = /\{=(.+?)=\}/

##
# Email template collection so it can be used on tests as well as
# seeding during new panel deployment.
EMAIL_TEMPLATE_COLLECTION = YAML.load_file(Rails.root.join('data/email_templates.yml'))

bots = YAML.load_file(Rails.root.join('data/bots.yml'))
BOTS_BY_BLOCKED_USER_AGENTS = bots['blocked_user_agents'].map(&:downcase)
BOTS_BY_IP_ADDRESSES = bots['blocked_ip_addresses']
BOTS_BY_REFERRER = bots['referrers'].map(&:downcase)
BOTS_BY_WHITELIST = bots['whitelisted_user_agents'].map(&:downcase)
BOTS_BY_IP_WHITELIST = bots['whitelisted_ip_addresses']
POSTBACK_WHITELISTED_USER_AGENTS = bots['postback_whitelisted_user_agents'].map(&:downcase)
ALL_BOTS = BOTS_BY_WHITELIST + BOTS_BY_BLOCKED_USER_AGENTS

blacklisted = YAML.load_file(Rails.root.join('data/blacklist.yml'))
BLACKLISTED_IPS = blacklisted['ip_addresses']
BLACKLISTED_S2S = blacklisted['s2s_postback_strings']
BLACKLISTED_AD_LINK_HOSTNAMES = blacklisted['ad_link_hostnames']

TRACK_CONVERSION_PATH_REGEX = /^\/track\/(conversions|postback).*$/
TRACK_JS_PATH_REGEX = /^\/track\/(imp\/mkt_site|slot\.json).*$/

# Default generatel cache duration to be used
# in any cache mechanic.
CACHE_DURATION = 7.days

##
# Pagination Setup
DEFAULT_PAGE = 1
DEFAULT_PER_PAGE = 50

##
# Integrated Platforms
INTEGRATED_PLATFORMS = {
  cyberbiz: 'CyberBiz',
  easystore: 'EasyStore',
  jooshop: 'Joo Shop',
  meepshop: 'Meep Shop',
  nineoneapp: '91 APP',
  oneshop: '1 Shop',
  qdm: 'QDM',
  shopline: 'Shopline',
  waca: 'WACA',
}

SERVER_TYPE = ENV.fetch('SERVER_TYPE')

MD5_REGEX = /\A[a-f0-9]{30,32}\z/i

DEFAULT_EMAIL_FROM = 'Affiliates.One Team <noreply@affiliates.one>'
