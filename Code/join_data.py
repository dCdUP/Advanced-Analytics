import pandas as pd

def main():

    # Read the two csvfiles
    player_data = pd.read_csv(r".\data\raw_data.csv",sep=",")
    role_data = pd.read_csv(r".\data\rollen.csv",sep=";")

    # Refactored percentages as floats to be used in R

    player_data["Team win percent after first kill"] = player_data["Team win percent after first kill"].str.rstrip("%").astype("float")/ 100.0
    player_data["First kill in won rounds"] = player_data["First kill in won rounds"].str.rstrip("%").astype("float")/ 100.0

    # Join both data sets
    combined_data_set = pd.merge(player_data,role_data,how="outer",on="Name")

    # save the joined data set into one CSV-File
    combined_data_set.to_csv(r".\data\finished_data.csv",index=False,sep=";")

    return 0

if __name__ == "__main__":
    main()