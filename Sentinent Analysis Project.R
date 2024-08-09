library(tidyverse)  # Load a collection of R packages for data manipulation and visualization
library(tidytext)  # Load package for text analysis
library(ggplot2)  # Load package for creating plots
library(dplyr)  # Load package for data manipulation
library(tidyr)  # Load package for tidying data
library(GGally)  # Load package for creating pairs plots

imdb_data = read_csv('IMDB Dataset.csv')  # Read data from a CSV file into a data table

# Check if there's an 'id' column; if not, create one with unique numbers
if (!"id" %in% colnames(imdb_data)) {
  imdb_data = imdb_data %>% mutate(id = row_number())  # Add a new column called 'id'
}

# Clean and prepare the review text
imdb_data = imdb_data %>%
  mutate(review = tolower(review)) %>%  # Convert all text to lowercase
  mutate(review = gsub('[[:punct:]]', '', review)) %>%  # Remove punctuation like periods and commas
  unnest_tokens(word, review) %>%  # Split text into individual words
  anti_join(stop_words)  # Remove common words like 'and' and 'the'

# Load sentiment dictionaries
bing_sentiments = get_sentiments("bing")  # Load Bing sentiment dictionary
imdb_data_bing = imdb_data %>%
  inner_join(bing_sentiments) %>%  # Combine the data with Bing sentiments
  group_by(id) %>%  # Group data by each review
  summarise(bing_sentiment = sum(ifelse(sentiment == "positive", 1, -1)))  # Calculate sentiment score

# Repeat for another sentiment dictionary (AFINN)
afinn_sentiments = get_sentiments("afinn")
imdb_data_afinn = imdb_data %>%
  inner_join(afinn_sentiments) %>%  # Combine with AFINN sentiments
  group_by(id) %>%  # Group by review
  summarise(afinn_sentiment = sum(value, na.rm = TRUE))  # Calculate sentiment score

# Repeat for another sentiment dictionary (NRC)
nrc_sentiments = get_sentiments("nrc") %>% 
  filter(sentiment %in% c("positive", "negative"))  # Filter only positive and negative sentiments
imdb_data_nrc = imdb_data %>%
  inner_join(nrc_sentiments) %>%  # Combine with NRC sentiments
  group_by(id) %>%  # Group by review
  summarise(nrc_sentiment = sum(ifelse(sentiment == "positive", 1, -1), na.rm = TRUE))  # Calculate sentiment score

# Combine all sentiment scores into one table
imdb_data_sentiments = imdb_data_bing %>%
  left_join(imdb_data_afinn, by = "id") %>%  # Add AFINN scores to the table
  left_join(imdb_data_nrc, by = "id")  # Add NRC scores to the table

# Function to normalize scores to a 0-1 range
normalize = function(x) {
  if (length(x) == 0) {
    return(x)  # Return as is if the input is empty
  }
  non_na_x = na.omit(x)  # Remove any missing values
  if (length(non_na_x) == 0) {
    return(rep(NA, length(x)))  # Return NA if no non-NA values
  }
  if (max(non_na_x) - min(non_na_x) == 0) {
    return(rep(0, length(x)))  # Return 0 if all values are the same
  } else {
    normalized_x = (non_na_x - min(non_na_x)) / (max(non_na_x) - min(non_na_x))  # Scale values to 0-1
    result = rep(NA, length(x))  # Create result vector with NA
    result[!is.na(x)] = normalized_x  # Fill in normalized values
    return(result)
  }
}

# Apply normalization to sentiment scores
imdb_data_sentiments = imdb_data_sentiments %>%
  mutate(bing_sentiment_normalized = normalize(bing_sentiment),
         afinn_sentiment_normalized = normalize(afinn_sentiment),
         nrc_sentiment_normalized = normalize(nrc_sentiment))

# Summary statistics for normalized sentiment scores
summary_bing = summary(imdb_data_sentiments$bing_sentiment_normalized)  # Get basic stats for Bing scores
summary_afinn = summary(imdb_data_sentiments$afinn_sentiment_normalized)  # Get basic stats for AFINN scores
summary_nrc = summary(imdb_data_sentiments$nrc_sentiment_normalized)  # Get basic stats for NRC scores

print("Summary Statistics for Normalized Bing Sentiment:")
print(summary_bing)

print("Summary Statistics for Normalized AFINN Sentiment:")
print(summary_afinn)

print("Summary Statistics for Normalized NRC Sentiment:")
print(summary_nrc)

# Save the results to a CSV file
write_csv(imdb_data_sentiments, 'IMDb_Reviews_with_Normalized_Sentiments_R.csv')  # Write data to a new CSV file

# Prepare data for plotting
imdb_data_sentiments_long = imdb_data_sentiments %>%
  pivot_longer(
    cols = c(bing_sentiment_normalized, afinn_sentiment_normalized, nrc_sentiment_normalized), 
    names_to = "Lexicon", 
    values_to = "Score"
  )

# Plot histogram of normalized sentiment scores
ggplot(imdb_data_sentiments_long, aes(x = Score, fill = Lexicon)) +
  geom_histogram(bins = 30, alpha = 0.6, position = "identity") +
  labs(title = "Distribution of Normalized Sentiment Scores", x = "Sentiment Score", y = "Frequency") +
  scale_fill_manual(values = c("blue", "green", "red")) +
  theme_minimal()

# Plot boxplot of sentiment scores across lexicons
ggplot(imdb_data_sentiments_long, aes(x = Lexicon, y = Score, fill = Lexicon)) +
  geom_boxplot(alpha = 0.6) +
  labs(title = "Boxplot of Sentiment Scores Across Lexicons", x = "Lexicon", y = "Sentiment Score") +
  scale_fill_manual(values = c("blue", "green", "red")) +
  theme_minimal() +
  theme(axis.text.x = element_blank())  # Remove x-axis text labels

# Plot violin plot of sentiment scores across lexicons
ggplot(imdb_data_sentiments_long, aes(x = Lexicon, y = Score, fill = Lexicon)) +
  geom_violin(alpha = 0.6) +
  labs(title = "Violin Plot of Sentiment Scores Across Lexicons", x = "Lexicon", y = "Sentiment Score") +
  scale_fill_manual(values = c("blue", "green", "red")) +
  theme_minimal() +
  theme(axis.text.x = element_blank())  # Remove x-axis text labels
