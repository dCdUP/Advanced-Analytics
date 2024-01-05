# Installiere ggplot2, wenn es noch nicht installiert ist
# install.packages("ggplot2")

# Lade das ggplot2-Paket
library(ggplot2)

# Erstelle Daten mit mindestens 10 Punkten
set.seed(123)  # Für die Reproduzierbarkeit der Zufallsdaten
x <- 1:10
y <- 2*x + rnorm(10)

# Erstelle ein Datenrahmen
data <- data.frame(x, y)

# Führe eine lineare Regression durch
lm_model <- lm(y ~ x, data=data)

# Neue Steigung für die Gerade
neue_steigung <- 1.5

# Projiziere die Punkte auf die Gerade mit der neuen Steigung
data$y_proj <- predict(lm_model, data) + (neue_steigung - coef(lm_model)[2]) * x

# Berechne die Varianz der auf die Gerade projizierten Punkte
var_proj <- var(data$y_proj)

# Erstelle die Plot-Grafik
ggplot(data, aes(x, y)) +
  geom_point(color = "#115E67", size = 3, shape = 16) +  # Füge Punkte hinzu und passe Farbe, Größe und Form an
  geom_abline(intercept = coef(lm_model)[1], slope = neue_steigung, linetype="solid", color="#D9C756") +  # Füge die Gerade mit neuer Steigung hinzu und passe Farbe und Linientyp an
  labs(x="X-Achse",
       y="Y-Achse") +
  theme_minimal() +  # Wähle ein minimalistisches Design
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),  # Zentriere und passe die Größe des Titels an
        axis.title = element_text(size = 12, face = "bold"),  # Passe die Größe der Achsentitel an
        axis.text = element_text(size = 10),  # Passe die Größe der Achsentexte an
        legend.position="none")  # Entferne die Legende (da wir keine spezifischen Legendeninformationen haben)
