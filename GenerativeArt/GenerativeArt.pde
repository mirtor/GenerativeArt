/*
Developer: Víctor Díaz Iglesias
Framework: Processing 4.2

The designed code generates lines of colors from the center of the screen outward, with random direction and speed.
Each generated circle is stored in an Array and removed from it upon destruction, avoiding system saturation.
When circles collide with the screen edge, they bounce in the opposite direction with the same color.
Next, each circle reaches the center of the screen again and is destroyed, causing the background circle's size to increase until it goes off the screen.
Additionally, a circle at the center of the screen is maintained, with a color inverse to that of the outer ring at all times.

It's possible to modify the screen size, and the code will still work correctly, as generic values have been used in its development (width/height).
The "growthRate" value in the global variables can also be modified. This will make the central ring increase in size more quickly.

Finally, using the mouse scroll, it's possible to modify the rate of line generation at the center of the screen, achieving interesting results with high values.

*/

ArrayList<Circle> circles = new ArrayList<Circle>(); // Array of circles

ColorCircle colorCircle; // Circle class definition
float diagonal; // Screen diagonal
color colorBack; // Background color
color colorCenter; // New color to be painted

int growthRate = 20; // Rate of growth for the central ring

int circleGeneration = 5; // Circle generation rate
int count = 0; // Count variable


void setup() {
  size(600, 600); // Screen size
  frameRate(180); // Frame update rate
  noStroke(); // No borders
  
  diagonal = dist(0, 0, width, height); // Calculate screen diagonal
  
  colorBack = color(255); // Background color white
  background(colorBack); // Set background color
  colorCenter = colorBack; // Set color for circles that clear content (specified later)

  colorCircle = new ColorCircle(); // Create an instance of the class defining the central circle
}

void draw() {
  
  count++; // Increment circle generation rate
  // Check and generate circles based on the generation rate, which can be modified using the mouse scroll
  if (count >= circleGeneration) {
    circles.add(new Circle()); // Generate a new circle and add it to the array
    count = 0; // Reset the count
  }

  // Loop through the array of generated circles
  for (int i = circles.size() - 1; i >= 0; i--) {
    Circle c = circles.get(i); // Store the current element of the array
    c.move(); // Access the class function that modifies the circle's behavior
    c.draw(); // Access the function that draws the circle on the screen
  
    // If the circle has been destroyed
    if (c.destroyed) {
      circles.remove(i); // Remove the circle from the array
      colorCircle.grow(); // Access the class that modifies the behavior of the central circle
    }
  }
  
  colorCircle.draw(); // Access the function of the class that draws the central circle, always displayed on the screen
 
}

// Function that checks mouse scroll using an event
void mouseWheel(MouseEvent event) {
  int count = event.getCount(); // Get the scroll value as data
  circleGeneration += -count * 3; // Modify the generation rate
  
  // Set limits to the generation rate
  circleGeneration = circleGeneration < 1 ? 1 : circleGeneration;
  circleGeneration = circleGeneration > 100 ? 100 : circleGeneration;

}

// Circle class definition. Controls the different lines of colors created on the screen
class Circle {
  float x = width/2; // Initial position on X-axis, center of the screen
  float y = height/2; // Initial position on Y-axis, center of the screen
  float speedX = random(-1, 1); // Random speed and direction on X
  float speedY = random(-1, 1); // Random speed and direction on Y
  
  float initialSize = 2; // Initial size of the circle
  float size = initialSize; // Current size of the circle
  
  color c = color(random(255), random(255), random(255)); // Random color
  
  boolean destroyed = false; // Tracker for circle destruction
  boolean increasedSize = false; // Tracker for increasing circle size when bouncing off edges

  // Function that modifies circle behavior
  void move() {
    // Update position based on random speed
    x += speedX; 
    y += speedY;

    // Detect collisions with screen edges
    if (x < size/2 || x > width - size/2 || y < size/2 || y > height - size/2) {
      // Change circle direction
      speedX *= -1; 
      speedY *= -1;
      c = colorBack; // Change color, same as background. Simulates erasing content on the screen
    
      if (!increasedSize) { // Increase size by 1 to cover the trace of the previous color
        size += 1; // Increase size
        increasedSize = true; // Size increase tracker
      }
    } else {
      increasedSize = false; // Reset tracker if not in contact with the edge
    }
  
    // When the circle clearing the screen content reaches the center, signal for its removal from the array
    if (c == colorBack && (x < (width/2) + 5) && (x > width/2)) {
      destroyed = true;
    }
  }

  // Function that draws the circle on the screen
  void draw() {
    noStroke(); // Remove circle borders
    fill(c); // Set random fill color
    ellipse(x, y, size, size); // Create the circle
  }
}

// Class definition for the central circle and ring on the screen
class ColorCircle {
  float x = width/2; // Initial position at the center
  float y = height/2; // Initial position at the center
  float size = 10; // Initial size of the central ring
 
  // Function that controls the behavior of the central circle
  void grow() {
    size += growthRate; // Increase size based on growth rate
  
    // If the circle size is larger than the screen diagonal
    if (size >= diagonal) {
      size = 10; // Reset to original size
      colorBack = colorCenter; // Update background color
      colorCenter = color(random(255), random(255), random(255)); // Update circle color  
    }
  }

  // Function that draws the central circle on the screen
  void draw() {
    fill(255 - red(colorCenter), 255 - green(colorCenter), 255 - blue(colorCenter)); // Calculate inverse color to the generated color for the outer ring
    ellipse(x, y, 30, 30); // Create the central circle
    
    stroke(colorCenter); // Border color
    strokeWeight(30); // Outer border thickness
    noFill(); // No fill
    arc(x, y, size, size, 0, TWO_PI); // Create the growing ring
  }
}
