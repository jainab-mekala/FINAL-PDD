# check_columns.py
import pandas as pd

df = pd.read_csv("data.csv")  # replace with your actual filename

print("Column names:")
print(df.columns.tolist())

print("\nFirst 3 rows:")
print(df.head(3))

print("\nShape:", df.shape)