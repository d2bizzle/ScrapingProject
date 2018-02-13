#knit together all ratings files
import glob
import pandas as pd
allFiles = glob.glob('*.csv')
ratings = pd.DataFrame()
filelist = []
for file_ in allFiles:
    df = pd.read_csv(file_,header=0)
    filelist.append(df)
ratings = pd.concat(filelist, ignore_index=True).reset_index(drop=True)
ratings.to_csv('ratings.csv')
