import pandas as pd  # Load package for data manipulation
from nltk.corpus import stopwords  # Load package for stop words
from nltk.tokenize import word_tokenize  # Load package for tokenizing text
import string  # Load package for string operations

# Load the IMDb dataset from a CSV file
imdb_data = pd.read_csv('IMDB Dataset.csv')

# Generate unique identifier if not present
if 'id' not in imdb_data.columns:
    imdb_data['id'] = range(1, len(imdb_data) + 1)  # Add a column with unique IDs for each review

# Preprocess the text data
stop_words = set(stopwords.words('english'))  # Define a set of common English stop words

def preprocess_text(text):
    text = text.lower()  # Convert text to lowercase
    text = text.translate(str.maketrans('', '', string.punctuation))  # Remove punctuation
    words = word_tokenize(text)  # Split text into individual words
    words = [word for word in words if word.isalpha() and word not in stop_words]  # Keep only alphabetic words and remove stop words
    return words

imdb_data['review'] = imdb_data['review'].apply(preprocess_text)  # Apply the preprocessing to each review
tokens_df = imdb_data.explode('review').rename(columns={'review': 'word'})  # Expand tokens and rename column to 'word'

# Load the sentiment lexicons
bing_sentiments = pd.read_csv('Bing_Lexicon.csv')  # Load Bing sentiment dictionary
afinn_sentiments = pd.read_csv('AFINN_Lexicon.csv')  # Load AFINN sentiment dictionary
nrc_sentiments = pd.read_csv('NRC_Lexicon.csv')  # Load NRC sentiment dictionary

# Perform sentiment analysis using Bing
bing_df = tokens_df.merge(bing_sentiments, left_on='word', right_on='word', how='inner')  # Combine tokens with Bing sentiments
if 'sentiment_x' in bing_df.columns:
    bing_df = bing_df.rename(columns={'sentiment_x': 'sentiment'})  # Resolve column name conflicts

bing_sentiment = bing_df.groupby('id').apply(lambda x: (x['sentiment'] == 'positive').sum() - (x['sentiment'] == 'negative').sum())  # Calculate sentiment score
bing_sentiment = bing_sentiment.reset_index(name='bing_sentiment')  # Reset index and name the sentiment column

# Repeat for AFINN sentiment dictionary
afinn_df = tokens_df.merge(afinn_sentiments, left_on='word', right_on='word', how='inner')  # Combine with AFINN sentiments
afinn_sentiment = afinn_df.groupby('id')['value'].sum().reset_index(name='afinn_sentiment')  # Calculate sentiment score

# Repeat for NRC sentiment dictionary
nrc_df = tokens_df.merge(nrc_sentiments, left_on='word', right_on='word', how='inner')  # Combine with NRC sentiments
if 'sentiment_y' in nrc_df.columns:
    nrc_df = nrc_df.rename(columns={'sentiment_y': 'sentiment'})  # Resolve column name conflicts

nrc_sentiment = nrc_df.groupby('id').apply(lambda x: (x['sentiment'] == 'positive').sum() - (x['sentiment'] == 'negative').sum())  # Calculate sentiment score
nrc_sentiment = nrc_sentiment.reset_index(name='nrc_sentiment')  # Reset index and name the sentiment column

# Combine all sentiment scores into one dataframe
imdb_data_sentiments = bing_sentiment.merge(afinn_sentiment, on='id').merge(nrc_sentiment, on='id')  # Merge all sentiment scores

# Normalize sentiment scores
def normalize(x):
    return (x - x.min()) / (x.max() - x.min())  # Scale values to a 0-1 range

# Apply normalization
imdb_data_sentiments['bing_sentiment_normalized'] = normalize(imdb_data_sentiments['bing_sentiment'])
imdb_data_sentiments['afinn_sentiment_normalized'] = normalize(imdb_data_sentiments['afinn_sentiment'])
imdb_data_sentiments['nrc_sentiment_normalized'] = normalize(imdb_data_sentiments['nrc_sentiment'])

# Summary statistics for normalized sentiment scores
summary_bing = imdb_data_sentiments['bing_sentiment_normalized'].describe()  # Get basic stats for Bing sentiment scores
summary_afinn = imdb_data_sentiments['afinn_sentiment_normalized'].describe()  # Get basic stats for AFINN sentiment scores
summary_nrc = imdb_data_sentiments['nrc_sentiment_normalized'].describe()  # Get basic stats for NRC sentiment scores

print("Summary Statistics for Normalized Bing Sentiment:")
print(summary_bing)

print("Summary Statistics for Normalized AFINN Sentiment:")
print(summary_afinn)

print("Summary Statistics for Normalized NRC Sentiment:")
print(summary_nrc)

# Save the results to a new CSV file
imdb_data_sentiments.to_csv('IMDb_Reviews_with_Normalized_Sentiments_py.csv', index=False)  # Save the results to a CSV file
