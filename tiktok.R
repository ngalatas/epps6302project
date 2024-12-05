#generate access token, saves it as 'access' for authorization

library(foreign)
library(httr)
library(stringr)
library(tidyr)
library(tidyverse)


headers = c(
  'Content-Type' = 'application/x-www-form-urlencoded',
  'Cache-Control' = 'no-cache'
)

body = list(
  'client_key' = 'aw6jhhp0d9b7yfpc',
  'client_secret' = 'Fu8Sz0ly0HtLucBBi24fn1pG4LQ6Uzv8',
  'grant_type' = 'client_credentials'
)

res <- POST(url = "https://open.tiktokapis.com/v2/oauth/token/", body = body, add_headers(headers), encode = 'form')
info <- (content(res))
access <- info$access_token
access <- paste("Bearer",access, sep = " ")

#ad query:
  #fields to return: ad.id, ad.first_shown_date, ad.last_shown_date
  #ad.status, ad.status_statement, ad.videos, ad.image_urls, ad.reach
  #advertiser.business_id, advertiser.business_name, advertiser.paid_for_by

  #filters: search_term, search_type (exact_phrase, fuzzy_phrase)
  #max_count (def 10, max 50), ad_published_date_range, country_code, 
  #advertiser_business_ids, unique_users_seen_size_range
  
  #unnesting and unlisting will differ based on fields

headers = c(
  'authorization' = access,
  'Content-Type' = 'application/x-www-form-urlencoded'
)

body = list(
  'filters' = '{"ad_published_date_range": {"min": "20240401","max": "20240601"}},"search_term": "pants", "search_type" = "exact_phrase", "country_code" = "US"}'
)

#getting response and selecting ad data
response <- POST(url = "https://open.tiktokapis.com/v2/research/adlib/ad/query/?fields=ad.id,ad.reach,ad.status,ad.videos,advertiser.business_name,advertiser.business_id,ad.first_shown_date,ad.last_shown_date", body = body, add_headers(headers), encode = 'form')
ads_list <- (content(response))
repeatid <- ads_list$data$search_id
ads_list <- ads_list$data$ads

#data formatting and converting to csv with ad vectors as rows

ads_df <- tibble(data = ads_list)
ads_df <- ads_df |> unnest_wider(data) |>
  unnest_wider(ad) |> unnest_wider(advertiser) |>
  unnest_longer(videos, keep_empty = TRUE) |> unnest_wider(videos) |>
  unnest_wider(reach)
ads_df$last_shown_date <- as.Date(ads_df$last_shown_date, "%Y%m%d")
ads_df$first_shown_date <- as.Date(ads_df$first_shown_date, "%Y%m%d")
ads_df$days_shown <- difftime(ads_df$last_shown_date, ads_df$first_shown_date, units = c("days"))

write.csv(ads_df, file = "C:/Users/nggal/OneDrive/Documents/R/projects/epps6302 - web/tiktokdata/ad_info.csv")

#advertiser query

  #fields to return: business_name, business_id, country_code
  #filters: search_term, max_count


headers = c(
  'Authorization' = access,
  'Content-Type' = 'application/json'
)

body = '{
  "search_term": "clothing",
  "max_count": 25
}';

res <- POST(url = "https://open.tiktokapis.com/v2/research/adlib/advertiser/query/?fields=business_id,business_name,country_code", body = body, add_headers(headers))

advertiser_list <- (content(res))
repeatid <- advertiser_list$data$search_id
advertiser_df <- tibble(data = advertiser_list$data$advertisers)
advertiser_df <- advertiser_df |> unnest_wider(data) 
write.csv(advertiser_df, file = "C:/Users/nggal/OneDrive/Documents/R/projects/epps6302 - web/tiktokdata/advertisers.csv")



//*[@id="ccContentContainer"]/div[2]/div[5]/div/div[1]/table



#video query
  #possible fields for return:id,video_description,create_time, region_code,share_count,view_count,like_count,comment_count, music_id,hashtag_names, username,effect_ids,playlist_id,voice_to_text, is_stem_verified, favourites_count, video_duration,hashtag_info_list,video_mention_list,video_label


headers = c(
  'Authorization' = access,
  'Content-Type' = 'application/json'
)

body = '{
  "query": {
    "and": [
      {
        "operation": "EQ",
        "field_name": "region_code",
        "field_values": [
          "US"
        ]
      },
      {
        "operation": "EQ",
        "field_name": "keyword",
        "field_values": [
          "clothing"
        ]
      }
    ],
  },
  "max_count": 100,
  "cursor": 0,
  "start_date": "20230101",
  "end_date": "20230115"
}';

res <- POST(url = "https://open.tiktokapis.com/v2/research/video/query/?fields=id,video_description,share_count,view_count,like_count,comment_count,hashtag_names,username,favourites_count,video_id,", body = body, add_headers(headers))

video_list <- (content(res))
repeatid <- video_list$data$search_id
video_df <- tibble(data = advertiser_list$data$videos)
video_df <- video_df |> unnest_wider(data) 
write.csv(advertiser_df, file = "C:/Users/nggal/OneDrive/Documents/R/projects/epps6302 - web/tiktokdata/video.csv")


#ad query

  #fields to return: ad.id, ad.first_shown_date, ad.last_shown_date,
  #ad.status, ad.status_statement, ad.videos, ad.image_urls, ad.reach
  #advertiser.business_id, advertiser.business_name, advertiser.paid_for_by
  #advertiser.follower_count, advertiser.avatar_url, advertiser.profile_url, ad_group.targeting_info

  #filters: ad_id

  #other info returned: ad_group, in targeting info (number_of_users_targeted, age,
  #gender, audience_targeting, video_interactions, creator_interactions, interest)
  #in reach (unique_users_seen, unique_users_seen_by_country)
  #in rejection info (reasons, affected_countries, reporting_source, automated_notice)

headers = c(
  'Authorization' = access,
  'Content-Type' = 'application/json'
)

body = '{
  "ad_id": ad.id
}';

res <- POST(url = "https://open.tiktokapis.com/v2/research/adlib/ad/detail/?fields=ad.id,ad.first_shown_date,ad.last_shown_date", body = body, add_headers(headers))

#data formatting and converting to csv with ad vectors as rows
detailed_list <- (content(res))
repeatid <- advertiser_list$data$search_id
write.csv(advertiser_df, file = "C:/Users/nggal/OneDrive/Documents/R/projects/epps6302 - web/tiktokdata/advertisers.csv")

#generate more with search id



# commerical query
  #fields: id, create_time_stamp, create_date, label, brand_names, creator, videos
  #filters: content_published_date_range, creator_country_code, creator_user_names

headers = c(
  'Authorization' = access,
  'Content-Type' = 'application/json'
)

body = '{
  "filters": {
    "content_published_date_range": {
      "min": "20240102",
      "max": "20240601"
    },
  }
}';

res <- POST(url = "https://open.tiktokapis.com/v2/research/adlib/commercial_content/report/?fields=ad_id,video_urls,business_name", body = body, add_headers(headers))

