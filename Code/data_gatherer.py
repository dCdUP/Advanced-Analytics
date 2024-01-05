from bs4 import BeautifulSoup
import csv, os


def get_data(file_path):
    player = open(file_path,"r",encoding="utf-8")
    soup = BeautifulSoup(player,"html.parser")
    stats = soup.find_all("div",class_="stats-row")

    raw_data = []
    player_name = soup.find("span",class_="context-item-name").text
    raw_data.append(player_name)

    for table in stats:
        i = 1
        for entry in table("span"):
            if entry.text == "K - D diff.":
                continue
            elif i % 2 == 0:
                raw_data.append(entry.text)
            i += 1
    

    
    return raw_data

def write_csv(data):
    header = ['Name','Kills', 'Deaths', 'Kill / Death', 'Kill / Round', 'Rounds with kills', 'Kill - Death difference', 'Total opening kills', 'Total opening deaths', 'Opening kill ratio', 'Opening kill rating', 'Team win percent after first kill', 'First kill in won rounds', '0 kill rounds', '1 kill rounds', '2 kill rounds', '3 kill rounds', '4 kill rounds', '5 kill rounds', 'Rifle kills', 'Sniper kills', 'SMG kills', 'Pistol kills', 'Grenade', 'Other','Role']
    f = open(".\\data\\raw_data.csv","w", encoding="utf8",newline="")
    csv_out = csv.writer(f)
    csv_out.writerow(header)
    csv_out.writerows(data)
    f.close()

def main():
    all_data = []
    dir_path = ".\\players"
    for entry in os.listdir(dir_path):
        joined_path = os.path.join(dir_path,entry)
        all_data.append(get_data(joined_path))
    write_csv(all_data)
    print("Done")

if __name__ == "__main__":
    main()