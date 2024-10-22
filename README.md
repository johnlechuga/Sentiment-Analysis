IMDB Sentiment Analysis with Multi-Lexicon Approach
This project explores sentiment analysis on the IMDB movie reviews dataset using multiple sentiment lexicons (BING, NRC, and AFINN). The goal is to compare how different lexicons score sentiments and demonstrate proficiency in both R and Python for natural language processing (NLP).

Table of Contents
1. Project Overview
2. Key Features
3. Data Cleaning and Preprocessing
4. Sentiment Analysis
5. Visualizations
6. Future Improvements
7. Acknowledgments

Project Overview
This project demonstrates sentiment analysis by leveraging three sentiment lexicons (BING, NRC, and AFINN). By comparing how these lexicons assign sentiment scores, I highlight key differences in their interpretation of the IMDB movie review dataset.

Additionally, I used both R and Python in this project to show my ability to translate code between the two languages and emphasize flexibility in utilizing different tools for data analysis.

Key Features
- Multi-Lexicon Sentiment Analysis: Utilizes BING, NRC, and AFINN lexicons to generate sentiment scores.
- Cross-Language Proficiency: Uses both R and Python to demonstrate versatility and code translation between languages.
- Data Visualizations: Includes histograms, boxplots, and violin plots to compare sentiment scores visually across different lexicons.

Data Cleaning and Preprocessing
The IMDB dataset consists of 50,000 movie reviews. To prepare it for sentiment analysis:

1. Text Normalization:
- Convert reviews to lowercase.
- Remove punctuation using regular expressions.
2. Tokenization and Stopword Removal:
- Break down the text into individual words (tokens).
- Filter out common stop words (e.g., "the", "and").
3. Sentiment Lexicons:
- Use the BING, AFINN, and NRC lexicons to score the sentiment of each review

Sentiment Analysis
Each lexicon assigns sentiment in a slightly different way:

- BING: Classifies words as either positive or negative, summing scores across the review.
- AFINN: Assigns integer scores between -5 and +5 to each word based on its emotional intensity.
- NRC: Contains more nuanced categories, but for this project, I focus on positive and negative sentiments.
After calculating sentiment scores for each lexicon, I normalized the results to allow for easier comparison.

Visualizations
Data visualizations were created to highlight the differences in sentiment scoring across lexicons. Three types of plots were generated:

- Histogram: Distribution of sentiment scores for each lexicon.
- Boxplot: Summary statistics showing sentiment score distribution.
- Violin Plot: Density and distribution of scores.

Future Improvements
- Sentiment by Genre: Analyze sentiment scores by movie genre to see if different genres elicit distinct sentiment profiles.
- Deep Learning: Explore advanced NLP techniques, such as transformers, to improve sentiment prediction accuracy.

Acknowledgments
- Dataset from Kaggle IMDB Dataset.
