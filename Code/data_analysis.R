#---- Start ----
#---- Libraries ----


library("corrplot")
library("caTools")
library("ggplot2")
library("ggfortify")
library("factoextra")
library("class")
library("rgl")
library("tictoc")
library("caret")
library("mosaic")
library("pROC")

#---- Read Data in ----


csdat <- read.csv("data/finished_data.csv",header=TRUE,dec=".",sep=";",stringsAsFactors = TRUE)


#---- add a characteristic which is relevant but not included in imported data ----

csdat$Sniper.Rifle.ratio <- csdat$Sniper.kills / csdat$Rifle.kills

# ---- Drop certain characteristics which are not relevant ----


csdat_focused <- subset(csdat,select = c("Kills","Deaths","Kill...Death","Kill...Round","Rounds.with.kills","Kill...Death.difference","Total.opening.kills","Total.opening.deaths","Opening.kill.ratio","Opening.kill.rating","Team.win.percent.after.first.kill","First.kill.in.won.rounds","X0.kill.rounds","X1.kill.rounds","X2.kill.rounds","X3.kill.rounds","X4.kill.rounds","X5.kill.rounds","Rifle.kills","Sniper.kills","Role","Team","Sniper.Rifle.ratio"))


#---- Do some error checking, if there are abnormalities in the data ----


player_with_most_frags <- csdat[csdat_focused$Kills == max(csdat_focused$Kills),]
player_with_most_deaths <- csdat[csdat_focused$Deaths == max(csdat_focused$Deaths),]


#---- Data exploration ----

corrplot.mixed(cor(csdat_focused[,-c(21,22)]), order = "hclust")
boxplot(csdat_focused$Total.opening.kills ~ csdat_focused$Role)
boxplot(csdat_focused$First.kill.in.won.rounds ~ csdat_focused$Role)
boxplot(csdat_focused$Total.opening.deaths ~ csdat_focused$Role)
boxplot(csdat_focused$Sniper.Rifle.ratio ~ csdat_focused$Role)

csdat_norifler <- csdat_focused[!(csdat_focused$Role == "Rifler"),]

#---- Principal component analysis ----

PCA <- prcomp(csdat_norifler[,-c(21,22)],scale. = TRUE)
summary(PCA)
fviz_eig(PCA,addlabels = TRUE,barfill = "#115E67",barcolor = "#ffffff",ncp = 6)
autoplot(PCA,data=csdat_norifler, colour = "Role",frame=TRUE)

#---- applying knn-algorithm ----

#standardize data
csdat_standardized <- data.frame(scale(csdat_norifler[,-c(21,22)]))

#how many rows of data are there
rows_of_data <- nrow(csdat_standardized)

#split relative amount
split <- 0.7

accuracy_of_ks_normal <- data.frame(
  amount_of_ks = integer(),
  accuracy_as_percent = double()
)

spliting_int <- round((split*rows_of_data),digits = 0)
#set seed for reproducability
set.seed(1)
random_rows <- sample(1:rows_of_data,spliting_int,replace = FALSE)
  
#splitting data into testing and training
training_data <- csdat_standardized[random_rows,]
testing_data <- csdat_standardized[-random_rows,]

training_categories <- csdat_norifler[random_rows,21]
testing_categories <- csdat_norifler[-random_rows,21]
  
#training model & getting most accurate amount of K's

accuracy <- function(x){sum(diag(x)/(sum(rowSums(x)))) * 100}

tic()
for (ks in 1:spliting_int){
  model <- knn(training_data,testing_data,training_categories,k=ks)
  confusion_matrix <- table(model,testing_categories)
  accuracy_of_ks_normal[nrow(accuracy_of_ks_normal)+1,] <- list(ks,accuracy(confusion_matrix))
}
toc()
ggplot(accuracy_of_ks_normal,aes(x=amount_of_ks,y=accuracy_as_percent))+ 
  geom_point(size = 3,color="#115E67") + 
  geom_point(data=accuracy_of_ks_normal[19,],aes(x=amount_of_ks,y=accuracy_as_percent), color= "#D9C756",size=5)+ 
  theme_minimal() + 
  scale_x_continuous(name="K") + 
  scale_y_continuous(name="Accuracy as percent") + 
  annotate(geom="text",x=25,y=75.25,label="K = 19") + 
  ggtitle(label="Genauigkeit des KNN-verfahren ohne PCA") + 
  theme(plot.title = element_text(hjust = 0.5))
accuracy_of_ks_normal[which.max(accuracy_of_ks_normal$accuracy_as_percent),]
text(accuracy_of_ks_normal)

#----see if PCA improves algo----

data_as_PCA <-data.frame(PCA$x[,1:6])

PCA_training_data <- data_as_PCA[random_rows,]
PCA_testing_data <- data_as_PCA[-random_rows,]

accuracy_of_ks_PCA <- data.frame(
  amount_of_ks = integer(),
  accuracy_as_percent = double()
)

tic()
for (ks in 1:spliting_int){
  model <- knn(PCA_training_data,PCA_testing_data,training_categories,k=ks)
  confusion_matrix <- table(model,testing_categories)
  matrix <- confusionMatrix(data=model,reference=testing_categories)
  accuracy_of_ks_PCA[nrow(accuracy_of_ks_PCA)+1,] <- list(ks,accuracy(confusion_matrix))
}
toc()

#print result and plot it

accuracy_of_ks_PCA[which.max(accuracy_of_ks_PCA$accuracy_as_percent),]
text(accuracy_of_ks_PCA)
ggplot(accuracy_of_ks_PCA,aes(x=amount_of_ks,y=accuracy_as_percent))+ 
  geom_point(size = 3,color="#115E67") + 
  geom_point(data=accuracy_of_ks_PCA[12,],aes(x=amount_of_ks,y=accuracy_as_percent), color= "#D9C756",size=5)+ 
  theme_minimal() + 
  scale_x_continuous(name="K") + 
  scale_y_continuous(name="Accuracy as percent") + 
  annotate(geom="text",x=18,y=78.02,label="K = 12") + 
  ggtitle(label="Genauigkeit des KNN-verfahren mit PCA") + 
  theme(plot.title = element_text(hjust = 0.5))

#---- test if the difference is significant ----


vertlg_normal <- do(1000)* accuracy(table(knn(training_data,testing_data,training_categories,k=19),testing_categories))
method_normal <- do(1000)*as.factor("normal")

df_normal <- data.frame(
  accuracy = vertlg_normal,
  method = method_normal
)
colnames(df_normal)[2] <- "method"


vertlg_pca <- do(1000)*accuracy(table(knn(PCA_training_data,PCA_testing_data,training_categories,k=12),testing_categories))
method_pca <- do(1000)*as.factor("pca")

df_pca <- data.frame(
  accuracy = vertlg_pca,
  method = method_pca
)
colnames(df_pca)[2] <- "method"


df <- rbind(df_normal,df_pca)

t.test(accuracy ~ method,data=df)

#---- get ROC and Gini of both of the algorithms ----

model_normal <- knn(training_data,testing_data,training_categories,k=19,prob = TRUE)
ROC_normal <- multiclass.roc(model_normal,attr(model_normal,"prob"),prob=TRUE)
Gini_normal <- 2*0.8604-1

model_PCA <- knn(PCA_training_data,PCA_testing_data,training_categories,k=12,prob = TRUE)
ROC_PCA <- multiclass.roc(model_PCA,attr(model_PCA,"prob"),prob=TRUE)
Gini_PCA <- 2*0.8012-1