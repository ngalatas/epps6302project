## Collecting Social Media data: YouTube

# Required Libraries
# Install if necessary
install.packages("tuber")
install.packages("tidyverse")
install.packages("lubridate")
install.packages("stringi")
install.packages("wordcloud")
install.packages("gridExtra")
install.packages("httr")
install.packages("tm")
install.packages("httpuv")
library("httpuv")
library(tuber)
library(tidyverse)
library(lubridate)
library(stringi)
library(wordcloud)
library(gridExtra)
library(httr)
library(tm)


### Step 1: Apply for the Google YouTube API


### 1.  Go to Google Cloud Console (https://cloud.google.com/).
### 2.  Create a new project or select an existing one.
### 3.  Search for and enable the YouTube Data API v3.
### 4.  Go to Credentials > Create Credentials > OAuth Client ID.
### 5.  Set up the OAuth consent screen
### 6.  Name the App (e.g. YouTube analyzer), enter support email
### 7.  Application type: web application
### 8.  Name: Web client 1
### 9.  Generate Client ID and Client Secret.
```

### Step 2: Authenticate with YouTube API

#### Use your Client ID and Client Secret to authenticate.

# Replace with your actual Client ID and Client Secret
yt_oauth("499646706541-p3mmqu3sobj10hqbd8nh63rm9khburdn.apps.googleusercontent.com", "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", token = "")

### Important:  when running for first time, you will be prompted to:
### 1. add the .httr-oauth to .gitignore, select 1 to consent. 
### 2. Then it will open browser to choose your Google account.  ### 3. When prompted with safety statement ("Google hasn’t verified this app"), click advanced and click Go to Appname (unsafe) to verify.  
### 4. When done, the message will show "Authentication complete. Please close this page and return to R."
### 5. Return to RStudio.  When seeing:
###  
### "Waiting for authentication in browser...
### Press Esc/Ctrl + C to abort
### Authentication complete.
### 
### It is ready to collect YouTube data
### CNN Channel ID: UCupvZG-5ko_eiXAupbDfxWw

### Step 3: Download YouTube Data


#### Search for videos related to "Fashion brand"
main_term <- "Lululemon shorts"
yt_fashion <- yt_search(term = paste(main_term, "clothing brand"))


#### Display the first few rows

head(yt_fashion)


### Step 4: Basic Analytics on YouTube Data

#### Most Frequent Words in Video Titles

# Extract titles and clean up

# Extract titles and clean up
titles <- yt_fashion$title
titles_clean <- tolower(titles) %>%
  stri_replace_all_regex("[[:punct:]]", "") %>%
  str_split(" ") %>%
  unlist()

# Create a word frequency table
word_freq <- table(titles_clean)
word_freq_df <- as.data.frame(word_freq, stringsAsFactors = FALSE)
colnames(word_freq_df) <- c("word", "freq")

# Filter common words (stop words) and plot a word cloud
word_freq_df <- word_freq_df %>% filter(!word %in% tm::stopwords("en"))
set.seed(123)
wordcloud(words = word_freq_df$word, freq = word_freq_df$freq, max.words = 50)


### 4.2. Plot Video Publish Dates

# Format publish dates and aggregate data


yt_sm <- yt_fashion %>%
  mutate(publish_date = as.Date(publishedAt)) %>%
  count(publish_date)

# Plot the frequency of videos published over time
ggplot(yt_sm, aes(x = publish_date, y = n)) +
  geom_line(color = "blue") +
  labs(title = "Videos Published Over Time", x = "Date", y = "Number of Videos") +  
  theme_bw()
###  4.3. Top Channels by Video Count


# Summarize by channel
top_channels <- yt_fashion %>%
  count(channelTitle, sort = TRUE) %>%
  top_n(10)

# Plot top channels
ggplot(top_channels, aes(x = reorder(channelTitle, n), y = n)) +
  geom_bar(stat = "identity", fill = "red") +
  coord_flip() +
  labs(title = "Top Channels on 'Fashion Brand'", x = "Channel", y = "Number of Videos")
