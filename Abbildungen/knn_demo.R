# Create data for green points (point cloud)
set.seed(123)  # Set seed for reproducibility
green_x <- rnorm(7, mean = 2, sd = 1)  # Decreased standard deviation
green_y <- rnorm(7, mean = 2, sd = 1)

# Create data for red points (point cloud)
red_x <- rnorm(7, mean = 6, sd = 1)  # Decreased standard deviation
red_y <- rnorm(7, mean = 6, sd = 1)

# Calculate the midpoint between red and green points
mid_x <- (max(green_x) + min(red_x)) / 2
mid_y <- (max(green_y) + min(red_y)) / 2

# Manually adjust plot window
x_margin <- 7
y_margin <- 5

# Plot green points with specified user coordinates
plot(1, type = "n", xlab = "", ylab = "", xlim = c(mid_x - x_margin, mid_x + x_margin), ylim = c(mid_y - y_margin, mid_y + y_margin))
points(green_x, green_y, col = "#D9C756", pch = 19)
points(red_x, red_y, col = "#115E67", pch = 19)
points(mid_x, mid_y, col = "black", pch = 19)

# Add legend outside the plot
legend("topleft", legend = c("AWP", "Lurker", "?"), col = c("#D9C756", "#115E67", "black"), pch = 19)