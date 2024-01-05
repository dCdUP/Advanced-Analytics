# Lade das ggplot2-Paket
library(ggplot2)
library(Cairo)

# Erstelle Daten mit mindestens 10 Punkten
set.seed(123)  # Für die Reproduzierbarkeit der Zufallsdaten
x <- 1:10
y <- 2*x + rnorm(10)

# Erstelle ein Datenrahmen
data <- data.frame(x, y)

# Führe eine lineare Regression durch
lm_model <- lm(y ~ x, data=data)

# Projiziere die Punkte auf die Gerade
data$y_proj <- predict(lm_model, data)

# Berechne die Varianz der auf die Gerade projizierten Punkte
var_proj <- var(data$y_proj)

# Erstelle die Plot-Grafik
ggplot(data, aes(x, y)) +
  geom_point(color = "#115E67", size = 3, shape = 16) +  # Füge Punkte hinzu und passe Farbe, Größe und Form an
  labs(x="X-Achse",
       y="Y-Achse") +
  theme_minimal() +  # Wähle ein minimalistisches Design
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),  # Zentriere und passe die Größe des Titels an
        axis.title = element_text(size = 12, face = "bold"),  # Passe die Größe der Achsentitel an
        axis.text = element_text(size = 10),  # Passe die Größe der Achsentexte an
        legend.position="none")  # Entferne die Legende (da wir keine spezifischen Legendeninformationen haben)
