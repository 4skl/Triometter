import java.util.Arrays;

float camX = 0;
float camY = 0;
float camZ = 0;
float camRotX = 0;
float camRotY = 0;
float zoomCount = 0;

int border = 100;

static Float[] rotate = new Float[3];
static Float[] axl = new Float[3];
static double[][] rotMatrix;

float maxSize = 1000000;

boolean shiftPressed = false;
public static ArrayList<TextEdit> textEdits = new ArrayList<TextEdit>();
public static ArrayList<ArrayList<Float[]>> points = new ArrayList<ArrayList<Float[]>>();
PGraphics scene3D;
PShape phone;
void setup(){
  
size(600, 600, P2D); 
scene3D = createGraphics(width-border, height-border, P3D);
/*phone = scene3D.loadShape("phone.obj");
phone.rotateX(PI/2);
phone.scale(20);*/
noStroke();
frameRate(60);

rotate[0] = 0f;
rotate[1] = 0f;
rotate[2] = 0f;

zoomCount = scene3D.height;

readNetworkPoints(4866);

textEdits.add(new TextEdit("Rot X : ",50,560,100,20));
textEdits.get(0).setText("0"); 
textEdits.add(new TextEdit("Rot Y : ",200,560,100,20));
textEdits.get(1).setText("0"); 
textEdits.add(new TextEdit("Rot Z : ",350,560,100,20));
textEdits.get(2).setText("0"); 

}

void readNetworkPoints(int port){
  NetworkReceiver net = new NetworkReceiver(port);
  Thread thread = new Thread(net);
  thread.start();
  
}

void readFilePoints(String fileName){
  File file = new File(fileName);
}

void draw(){
background(0);
for(int i = 0;i<3;i++){
try{
rotate[i] = Float.parseFloat(textEdits.get(i).getText())/180*PI;
}catch(NumberFormatException e){
//textEdits.get(i).setText(""+rotate[i]/(PI)*180); 
}
}
text("x : " + rotate[0]/(PI)*180 +"°"+ "\ny : " + rotate[1]/(PI)*180 +"°" + "\nz : " + rotate[2]/(PI)*180 +"°" ,10,10);
text("x : " + axl[0] +" m/s²"+ "\ny : " + axl[1] +" m/s²" + "\nz : " + axl[2] +" m/s²" ,200,10);
if(scene3D.height!= height-border || scene3D.width!= width-border) scene3D = createGraphics(width-border, height-border, P3D);

scene3D.beginDraw();
scene3D.beginCamera();
scene3D.camera();
//camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
scene3D.translate(camX,camY,camZ);
scene3D.rotateX(camRotY);
scene3D.rotateY(camRotX);
scene3D.perspective(PI/3.0, scene3D.width/scene3D.height, 1, maxSize);
scene3D.endCamera();
scene3D.background(255);
scene3D.lights();
scene3D.strokeWeight(1);

//Landmark
scene3D.pushMatrix();
float widthO = 1;
float heightO = scene3D.height;
scene3D.stroke(255,0,0);
scene3D.translate(heightO/2,0,0);
scene3D.box(heightO,widthO,widthO);
scene3D.stroke(0,255,0);
scene3D.translate(-heightO/2,0,0);
scene3D.translate(0,heightO/2,0);
scene3D.box(widthO,heightO,widthO);
scene3D.stroke(0,0,255);
scene3D.translate(0,-heightO/2,0);
scene3D.translate(0,0,heightO/2);
scene3D.box(widthO,widthO,heightO);
scene3D.popMatrix();
//
scene3D.pushMatrix();
//System.out.println("Rotate bf : " + Arrays.toString(rotate)); 
scene3D.rotateX(rotate[0]);
scene3D.rotateY(rotate[1]);
scene3D.rotateZ(rotate[2]);
widthO = 2;
heightO = scene3D.height/2;
scene3D.stroke(128,0,0);
scene3D.translate(heightO/2,0,0);
scene3D.box(heightO,widthO,widthO);
scene3D.stroke(0,128,0);
scene3D.translate(-heightO/2,0,0);
scene3D.translate(0,heightO/2,0);
scene3D.box(widthO,heightO,widthO);
scene3D.stroke(0,0,128);
scene3D.translate(0,-heightO/2,0);
scene3D.translate(0,0,heightO/2);
scene3D.box(widthO,widthO,heightO);
scene3D.popMatrix();

//Drawing rotated vector
/*scene3D.pushMatrix();
int sz = 250;
float[] vector = {sz,sz,sz};
double[] globalVector = globalizeAcceleration(floatArrayToDouble(vector),floatArrayToDouble(objectFloatToFloat(rotate)));
float[] fGlobalVector = doubleArrayToFloat(globalVector);
text("x : " + fGlobalVector[0]+ "\ny : " + fGlobalVector[1] + "\nz : " + fGlobalVector[2] ,400,10);
scene3D.stroke(50);
scene3D.line(0,0,0,fGlobalVector[0],fGlobalVector[1],fGlobalVector[2]);
//x
vector = new float[]{sz,0,0};
globalVector = globalizeAcceleration(floatArrayToDouble(vector),floatArrayToDouble(objectFloatToFloat(rotate)));
fGlobalVector = doubleArrayToFloat(globalVector);
//text("x : " + fGlobalVector[0]+ "\ny : " + fGlobalVector[1] + "\nz : " + fGlobalVector[2] ,400,10);
scene3D.stroke(128,0,0);
scene3D.line(0,0,0,fGlobalVector[0],fGlobalVector[1],fGlobalVector[2]);
//y
vector = new float[]{0,sz,0};
globalVector = globalizeAcceleration(floatArrayToDouble(vector),floatArrayToDouble(objectFloatToFloat(rotate)));
fGlobalVector = doubleArrayToFloat(globalVector);
//text("x : " + fGlobalVector[0]+ "\ny : " + fGlobalVector[1] + "\nz : " + fGlobalVector[2] ,400,10);
scene3D.stroke(0,128,0);
scene3D.line(0,0,0,fGlobalVector[0],fGlobalVector[1],fGlobalVector[2]);
//z
vector = new float[]{0,0,sz};
globalVector = globalizeAcceleration(floatArrayToDouble(vector),floatArrayToDouble(objectFloatToFloat(rotate)));
fGlobalVector = doubleArrayToFloat(globalVector);
//text("x : " + fGlobalVector[0]+ "\ny : " + fGlobalVector[1] + "\nz : " + fGlobalVector[2] ,400,10);
scene3D.stroke(0,0,128);
scene3D.line(0,0,0,fGlobalVector[0],fGlobalVector[1],fGlobalVector[2]);
scene3D.popMatrix();*/

//Draw trace
Float[] point = new Float[3];
for(int i = 0;i<points.size();i++){
  scene3D.beginShape(LINE_STRIP);
  scene3D.stroke((int) ((((float)i)/points.size())*(255*255*255)));
  for(int j = 0;j<points.get(i).size();j++){
    point = points.get(i).get(j);
    scene3D.vertex(point[0],point[1],point[2]);
  }
  scene3D.endShape();
}
/*if(axl[0]!=null){
scene3D.pushMatrix();
scene3D.specular(255,100,0);
  scene3D.translate(axl[0],axl[1],axl[2]);
  scene3D.sphere(10);
  scene3D.popMatrix();
}*/
if(rotMatrix != null){
scene3D.pushMatrix();
scene3D.translate(point[0], point[1], point[2]);
double[] rotatedVector = {250,0,0};
double[] globalizedVector = vectorByMatrix(rotatedVector,rotMatrix);
scene3D.stroke(250,0,0);
scene3D.line(0,0,0,(float)globalizedVector[0],(float)globalizedVector[1],(float)globalizedVector[2]);
rotatedVector = new double[]  {0,250,0};
globalizedVector = vectorByMatrix(rotatedVector,rotMatrix);
scene3D.stroke(0,250,0);
scene3D.line(0,0,0,(float)globalizedVector[0],(float)globalizedVector[1],(float)globalizedVector[2]);
rotatedVector = new double[] {0,0,250};
globalizedVector = vectorByMatrix(rotatedVector,rotMatrix);
scene3D.stroke(0,0,250);
scene3D.line(0,0,0,(float)globalizedVector[0],(float)globalizedVector[1],(float)globalizedVector[2]);
scene3D.popMatrix();
}

/*scene3D.pushMatrix();
scene3D.rotateX(rotate[0]);
scene3D.rotateY(rotate[1]);
scene3D.rotateZ(rotate[2]);
scene3D.shape(phone,0,0);
if(axl[0] != null){
scene3D.line(0,0,0,axl[0]*10,axl[1]*10,axl[2]*10);
}
scene3D.popMatrix();*/

scene3D.endDraw();
for(TextEdit text : textEdits) text.onDraw();
image(scene3D,50,50,width-100,height-100);

}




//Utils


double[] globalizeAcceleration(double[] relativeAcceleration, double[] rotation){
        double[] globalAxl = relativeAcceleration;
        globalAxl = vectorByMatrix(globalAxl,getRotXMatrix(-rotation[0]));
        globalAxl = vectorByMatrix(globalAxl,getRotYMatrix(-rotation[1]));
        globalAxl = vectorByMatrix(globalAxl,getRotZMatrix(-rotation[2]));
        return globalAxl;
    }
    
    double[][] getRotXMatrix(double angleX){
        return new double[][]{{1,0,0},
                {0, Math.cos(angleX), -Math.sin(angleX)},
                {0, Math.sin(angleX), Math.cos(angleX)}
        };
    }
    double[][] getRotYMatrix(double angleY){
        return new double[][]{
                {Math.cos(angleY), 0, Math.sin(angleY)},
                {0, 1, 0},
                {-Math.sin(angleY), 0, Math.cos(angleY)}
        };
    }
    double[][] getRotZMatrix(double angleZ){
        return new double[][]{
                {Math.cos(angleZ), -Math.sin(angleZ), 0},
                {Math.sin(angleZ), Math.cos(angleZ), 0},
                {0, 0, 1}
        };
    }
    
    public static double[] vectorByMatrix(double[] vector, double[] matrix){//row-major
    if(matrix.length%vector.length != 0) return null;
    double[] newMatrix = new double[matrix.length/vector.length];
    for(int i = 0;i<matrix.length;i++){
      newMatrix[i/(newMatrix.length)] += vector[i%newMatrix.length]*matrix[(i%newMatrix.length)*newMatrix.length + i/newMatrix.length];
    }
    return newMatrix;
    }
  
    double[] vectorByMatrix(double[] vector, double[][] matrix){
        if(vector.length != matrix.length) return null;//Verify (need to verify if matrix is a true matrix)
        double[] newMatrix = new double[matrix[0].length];
        for(int j = 0;j<matrix[0].length;j++){
            for(int i = 0;i<vector.length;i++){
                newMatrix[j] += vector[i]*matrix[i][j];
            }
        }
        return newMatrix;
    }
    
    float[] doubleArrayToFloat(double[] arr){
      float[] nArr = new float[arr.length];
      for(int i = 0;i<arr.length;i++) nArr[i] = (float) (arr[i]);
      return nArr;
    }
    
    double[] floatArrayToDouble(float[] arr){
      double[] nArr = new double[arr.length];
      for(int i = 0;i<arr.length;i++) nArr[i] = (double) (arr[i]);
      return nArr;
    }
    
    float[] objectFloatToFloat(Float[] arr){
      float[] nArr = new float[arr.length];
      for(int i = 0;i<arr.length;i++)nArr[i] = arr[i];
      return nArr;
    }
    
    ///

void mouseDragged(){
  if(keyPressed && key == CODED && keyCode == SHIFT){
    moveCam(mouseX-pmouseX,mouseY-pmouseY);
  }else{
    rotateCam(mouseX-pmouseX,mouseY-pmouseY);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  //println(e);
  zoomCam(e);
}

void keyPressed(){
  for(TextEdit text : textEdits) text.onKey();
  if(key == 'c'){
      zoomCount = 0;
      camX = 0;
      camY = 0;
      camZ = 0;
      camRotY = 0;
      camRotX = 0;
  }else if(key == 'z'){
    camRotX = 0;
    camRotY  = -PI;
  }else if(key == 'y'){
    camRotX = 0;
    camRotY = -PI/2;
  }else if(key == 'x'){
    camRotX = PI/2;
    camRotY = 0;
  }
}

void mousePressed(){
  for(TextEdit text : textEdits) text.onPress();
}

void rotateCam(float xMov, float yMov){
  
camRotX += xMov*(PI/(width/4));
camRotY += -yMov*(PI/(height/4));
}

void moveCam(float xMov, float yMov){
camX += xMov;
camY += yMov;
}

void zoomCam(float factor){
zoomCount += factor;
camZ += -(Math.abs(Math.pow(zoomCount*(1e-3*5),3)))*factor;//-factor*exp(zoomCount);//-abs(factor)*exp(zoomCount/10);
//println(factor*exp(zoomCount/10) + " count : " + zoomCount);
}

//si fact + 1 zoom * 2
float log10 (float x) {
  return (log(x) / log(10));
}


public class TextEdit{
      String label = "",text = "";
      float x,y,wx,wy;
      float borderSize = 0.5f;
      float textSize = 12;
      boolean selected = false;
      color strokeColor;
      color fillColor;
      color selectedStrokeColor;
      color selectedFillColor;
      color textColor;
      PGraphics graphics;
      int cursorPos = 0;
      public TextEdit(String label, float x, float y, float wx, float wy){
      this.label = label;
      this.x = x;
      this.y = y;
      this.wx = wx;
      this.wy = wy;
      strokeColor = color(64,64,64);
      fillColor = color(128,128,128);
      selectedStrokeColor = color(64,64,255);
      selectedFillColor = color(255,255,255);
      textColor = color(0,0,0);
      graphics = createGraphics((int)wx,(int)wy,P2D);
      }
      
      public void onDraw(){
      //rect(x,y,wx+borderSize,wy+borderSize);
      graphics.beginDraw();
      if(selected){
      graphics.fill(selectedFillColor);
      graphics.stroke(selectedStrokeColor);
      }else{
      graphics.fill(fillColor);
      graphics.stroke(strokeColor);
      }
      graphics.textSize(textSize);
      graphics.text(label,0,wy/1.5);
      graphics.rect(textWidth(label),0,wx,wy);
      graphics.fill(textColor);
      graphics.text(text,textWidth(label),wy/1.5);
      graphics.endDraw();
      image(graphics,x,y,wx,wy);
      }
      
      public void onPress(){
        selected = ((mouseX > x && mouseX < x+wx+textWidth(label)) && (mouseY > y && mouseY <y+wy));
      }
      
      public void onKey(){
        if(selected){
        if(key==BACKSPACE){
          String sTemp = "";
          for(int i = 0;i<text.length()-1;i++) sTemp += text.charAt(i);
          text = sTemp;
        }else if(key==ENTER){
          selected = false;
        }else{
          text += key;
        }
        }
      
      }
      
      public String getText(){
        return text;
      }
      
      public void setText(String text){
        this.text = text;
      }
}
