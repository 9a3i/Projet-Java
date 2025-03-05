PImage img;
PFont f; 

float zoom = 1.0;

boolean boutonS = false;
boolean zoneselect = false;
boolean zoneactive = false;
boolean selectcomplete = false;
int startX, startY, endX, endY;

void setup() {
  background(255);
  size(416,416);
  img = loadImage("inrainbows.png");
  f = createFont("Helvetica",12);

}
void draw () {
  background(255);
  // Cette partie du code charge l'image dans la fenêtre
  image(img,165 - 120*zoom, 190 - 120*zoom, 316*zoom ,316*zoom);
  strokeWeight(1);
  
  loadPixels();
  
// barre d'outils
  stroke(0);
  fill(200);
  rect(0,0,width,45);

  if (boutonS == false){  // si on appuie sur le bouton S, il devient vert
    bouton(45,15,20,20, "S",125,125,125);
  }
  else { 
    bouton(45,15,20,20, "S",0,255,0);
  }
  
  bouton(300,15,20,20, "B",125,125,125);
  bouton(335,15,20,20, "I",125,125,125);
  bouton(370,15,20,20, "G",125,125,125);
  bouton(80, 15, 20, 20, "+", 125, 125, 125);
  bouton(115, 15, 20, 20, "-", 125, 125, 125);
  
//zone de sélection
  if (zoneselect) {
    strokeWeight(2);
    stroke(0,255,0);
    noFill();
    rect(startX, startY, mouseX - startX, mouseY - startY);
  } 
  else if (zoneactive) {
    strokeWeight(2);
    stroke(0,255,0);
    noFill();
    rect(startX, startY, endX - startX, endY - startY);
  }

}
//fonction qui blur un pixel
color blurPixel(int startX,int startY){
  float r = 0;
  float g = 0;
  float b = 0;
  int n = 0 ; 
  
  for (int sidepixX = -1; sidepixX <= 1; sidepixX++) {
    for (int sidepixY = -1; sidepixY <= 1; sidepixY++) {
      int x2 = startX + sidepixX;
      int y2 = startY + sidepixY;
      
      if (x2 >= 0 && x2 <img.width && y2 >= 0 && y2 < img.height) {
        color pixel = img.pixels [img.width*y2+x2];
        r+= red(pixel);
        g+= green(pixel);
        b+= blue(pixel);
        n++;
      }
    }
  }
  return color (r/n, g/n, b/n);
}

void mousePressed () {
  
  
  if(mouseX < 65 && mouseX > 45 && mouseY < 35 && mouseY > 15){
    boutonS = !boutonS; // active et désactive le bouton "S"
    zoneactive = false; // réinitialise la zone active 
    selectcomplete = false; // permet de redémarrer une sélection
  }

  if(mouseX < 320 && mouseX > 300 && mouseY < 35 && mouseY > 15) {
    applyfiltre("blur");
    
  }

  if(mouseX < 355 && mouseX > 335 && mouseY < 35 && mouseY > 15) {   
    applyfiltre("invert");
  }

  if(mouseX < 390 && mouseX > 370 && mouseY < 35 && mouseY > 15) {
    applyfiltre("grayscale");
  } 
  if (mouseX > 80 && mouseX < 100 && mouseY > 15 && mouseY < 35 && zoom < 2) {
    zoom += 0.1;
  }
  if (mouseX > 115 && mouseX < 135 && mouseY > 15 && mouseY < 35 && zoom > 0) {
     zoom -= 0.1;
  }
  
  if (boutonS && mouseX > 50 && mouseX < 366 && mouseY > 75 && mouseY < 391) {
    if (!zoneselect && !selectcomplete) {
      // Début de la sélection
      startX = mouseX;
      startY = mouseY;
      zoneselect = true;
      zoneactive = false;
    } else if (zoneselect) {
      // Fin de la sélection
      endX = mouseX;
      endY = mouseY;
      zoneselect = false;
      zoneactive = true;
      boutonS = false; // Désactive le bouton "S" après sélection
      selectcomplete = true; // Empêche une nouvelle sélection immédiate
    }
  }


}
// fonction pour les boutons 
void bouton(float x, float y, float w, float h, String lettre, int colR, int colG, int colB) {
  stroke(0);              
  fill(colR,colG,colB);               
  rect(x, y, w, h);        
  fill(0);                 
  text(lettre, x + w/2, y + h/2); 
} 
//fonction pour appliquer les filtres dans la zone sélectionnée
void applyfiltre(String filtre) {
  int x1, y1, x2, y2;
  if (!zoneactive) {
    x1 = 0;
    y1 = 0;
    x2 = img.width;
    y2 = img.height;
  } else {
    x1 = (int)((min(startX, endX) - 165 + 120*zoom) /zoom);
    y1 = (int)((min(startY, endY) - 190 + 120*zoom) /zoom);
    x2 = (int)((max(startX, endX) - 165 + 120*zoom) /zoom);
    y2 = (int)((max(startY, endY) - 190 + 120*zoom) /zoom);
  }

 
  if (filtre == "invert") {
    invert(x1, y1, x2 - x1, y2 - y1);
  } else if (filtre == "grayscale") {
    grayscale(x1, y1, x2 - x1, y2 - y1);
  } else if (filtre == "blur") {
    blur(x1, y1, x2 - x1, y2 - y1);
  }
}

// fonction pour l'effet flou
void blur(int x, int y, int w, int h) {
  img.loadPixels();
  for (int i = x; i < x + w; i++){
    for (int j = y; j < y + h; j++) {
      int index = i + j * img.width;
      img.pixels[index] = blurPixel(i,j);
    }
  }
  img.updatePixels();
} 

 // fonction pour inverser les couleurs
void invert(int x, int y, int w, int h) {
  img.loadPixels();
  for (int i = x; i < x + w; i++) {
    for (int j = y; j < y + h; j++) {
      int index = i + j * img.width;
      color c = img.pixels[index];
      float r = 255 - red(c);
      float g = 255 - green(c);
      float b = 255 - blue(c);
      img.pixels[index] = color(r,g,b);
    }
  }
  img.updatePixels();
}

// fonction pour les couleurs noir/blanc/gris
void grayscale(int x, int y, int w, int h) {
  img.loadPixels();
  for (int i = x; i < x + w; i++) {
    for (int j = y; j < y + h; j++) {
      int index = i + j * img.width;
      color c = img.pixels[index];
      img.pixels[index] = color((blue(c)+green(c)+red(c))/3);
    }
  }
  img.updatePixels();
}

void keyPressed () {
  if(key=='s'){
    println("Fichier sauvegardé");
  }
}
