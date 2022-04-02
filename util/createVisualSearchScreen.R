# options
size <- 5
grid_stepsize <- 10
positive <- TRUE
distractor_letters <- c('T', 'K')
distractor_colors <- c('blue', 'red')
target_letter <- 'U'
target_color <- 'purple'

save_image <- FALSE
file_name <- 'image_1'



# create grid
grid <- seq(1, 99, by = grid_stepsize)
grid <- data.frame('position'=  1:length(grid)**2,
                   'x'=  rep(grid, each = length(grid)),
                   'y'=  rep(grid, times = length(grid)))

# select positions randomly from grid
positions <- grid[sample(x = 1:nrow(grid), size = size,replace = FALSE),]

# create letters
letters <- rep(distractor_letters, times = round(size/2)+1)[1:size]
letters_colors <- rep(distractor_colors, times = round(size/2)+1)[1:size]

# set target position
if(positive){
  letters[length(letters)] <- target_letter
  letters_colors[length(letters)] <- target_color
}

if(save_image){
  png(sprintf("%s.png", file_name))
}

# Custom symbols
plot(positions$x, positions$y, pch = letters,
     col = letters_colors, cex = 3,
     xlim = c(0, 99), ylim = c(0, 99), ylab="",yaxt="n", xlab="",xaxt="n")

if(save_image){
  dev.off()
}
