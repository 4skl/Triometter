package com.medi.triometter;

import android.app.Activity;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.util.Pair;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.ArrayList;

public class MainActivity extends Activity implements SensorEventListener {
    public int mouseX,mouseY;
    Button connectBtn,flatBtn,startBtn;
    EditText ipEdit,portEdit,freqSendEdit;


    ArrayList<Pair<Long,Float[]>> axl = new ArrayList<>();
    ArrayList<Pair<Long,Float[]>> rot = new ArrayList<>();
    ArrayList<Pair<Long,float[]>> matrixRot = new ArrayList<>();
    double[] gravity = null;
    int lastIndex = 1;
    double[] lastSpeed = new double[3];
    double[] lastPos = new double[3];
    float[] actualRotMatrix = null;
    double resolution = 0.01;

    boolean started = false;
    
    long timer = 0;

    SensorManager sensorManager;

    // L'accéléromètre
    Sensor accelerometer;
    Sensor rotationSensor;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);


        // Instancier le gestionnaire des capteurs, le SensorManager
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        // Instancier l'accéléromètre
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        rotationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);

        connectBtn = (Button) findViewById(R.id.connectBtn);
        ipEdit = (EditText) findViewById(R.id.ipText);
        portEdit = (EditText) findViewById(R.id.portText);
        freqSendEdit = (EditText) findViewById(R.id.freqSendPosText);

        connectBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startConnect();
            }
        });
        flatBtn = (Button) findViewById(R.id.flatingButton);
        flatBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                actualizeGravity();
            }
        });
        startBtn = (Button) findViewById(R.id.strtBtn);
        startBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                started = true;
            }
        });

    }

    public void startConnect(){
        final MainActivity activity = this;
        new Thread(new Runnable() {
            @Override
            public void run() {
                started = true;
                if (gravity == null) actualizeGravity();
                while (gravity == null);
                String ip = ipEdit.getText().toString();
                int port = Integer.parseInt(portEdit.getText().toString());
                int freq = Integer.parseInt(freqSendEdit.getText().toString());
                int period = 1000/freq;
                mouseX = mouseY = 0;
                PosSender posSender = new PosSender(period, activity, ip, port);
                Thread thread = new Thread(posSender);
                thread.start();
            }}).start();
    }


    @Override
    protected void onPause() {
        // unregister the sensor (désenregistrer le capteur)
        sensorManager.unregisterListener(this, accelerometer);
        sensorManager.unregisterListener(this,rotationSensor);

        super.onPause();
    }

    @Override
    protected void onResume() {
        sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_FASTEST);
        sensorManager.registerListener(this,rotationSensor, SensorManager.SENSOR_DELAY_FASTEST);
        super.onResume();
    }

/********************************************************************/
/** SensorEventListener*************************************************/
    /********************************************************************/

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

        if(sensor.getType() == Sensor.TYPE_ACCELEROMETER) resolution = sensor.getResolution();
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        // Récupérer les valeurs du capteur
        if (started) {
            float x, y, z;
            switch (event.sensor.getType()) {
                case Sensor.TYPE_ACCELEROMETER :
                    //Ici je récupère les valeurs d'accélération suivant les 3 axes du téléphone
                    x = event.values[0];
                    y = event.values[1];
                    z = event.values[2];
                    //Et je stocke ces valeurs dans l'ArrayList "axl", avec leur timestamp associé
                    axl.add(new Pair(event.timestamp,new Float[]{x, y, z}));
                    break;

                case Sensor.TYPE_ROTATION_VECTOR:
                    //Ici je récupère  un vecteur de rotations
                    x = event.values[0]*(float)Math.PI;
                    y = event.values[1]*(float)Math.PI;
                    z = event.values[2]*(float)Math.PI;
                    //Valeurs de rotation que je transforme en matrice de rotation plus utile
                    actualRotMatrix = new float[9];
                    SensorManager.getRotationMatrixFromVector(actualRotMatrix, event.values);
                    //Je stocke ces valeurs dans des ArrayList
                    matrixRot.add(new Pair(event.timestamp,actualRotMatrix));
                    rot.add(new Pair(event.timestamp,new Float[]{x, y, z}));
                    break;
            }
        }

    }

    void actualizeGravity(){
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (axl.size() == 0 || rot.size() == 0) {
                    started = true;
                }
                while (axl.size() < 1 || actualRotMatrix == null) ;
                Pair<Long, Float[]> flat = axl.get(axl.size() - 1);
                float[] axl = new float[flat.second.length];
                for(int i = 0;i<axl.length;i++) axl[i] = flat.second[i];
                float[] rotMatrix = actualRotMatrix;
                rotMatrix = transpose(actualRotMatrix,(int) Math.sqrt(actualRotMatrix.length));
                float[] grav = vectorByMatrix(axl,rotMatrix);
                gravity = new double[]{grav[0],grav[1],grav[2]};//To be atomic ?
                lastSpeed = new double[3];
                System.out.println("Gravity vector is : \n" + "x : " + gravity[0] + "\ny : " + gravity[1] + "\nz : " + gravity[2]);
            }
        }).start();
    }

    public static double[] floatArrayToDoubleBasic(Float[] array){
        double[] out = new double[array.length];
        for(int i = 0;i<array.length;i++){
            out[i] = array[i];
        }
        return out;
    }

    public double[]calculateMove(long time){

        int axlCount = axl.size();
        int rotCount = rot.size();

        if(axlCount < 2 || rotCount < 2) return null;

        int axlEndIndex = 0;

        if(axl.get(axlCount-1).first < time) return null;//predict

        for(int i = axlCount-2;i>=0;i--){
            if(axl.get(i).first < time ){
                axlEndIndex = i+1;
                break;
            }
        }


        if(rot.get(rotCount-1).first < time) return null;//predict


        double[] oldSpeed = new double[3];
        double[] oldPos = new double[3];
        for(int i = 1;i<axlEndIndex;i++){
            Pair<Long,Float[]> prevAxl = axl.get(i-1);
            Pair<Long,Float[]> nextAxl = axl.get(i);//can be at the time

            double t = nextAxl.first/1e9 - prevAxl.first/1e9;

            Float[] relativeAxl = nextAxl.second;

            double[] absoluteAxl = new double[3];
            for(int j = 0;j<3;j++) absoluteAxl[j] = relativeAxl[j];



            double[] pos = new double[3];
            for(int j = 0;j<3;j++){
                //absoluteAxl[j]-=gravity[j];
                pos[j] = 0.5*absoluteAxl[j]*Math.pow(t,2) + oldSpeed[j]*t + oldPos[j];
                oldSpeed[j] = oldSpeed[j]+absoluteAxl[j]*t;
                oldPos[j] = pos[j];
            }

        }

        return oldPos;
    }

    public static double[] vectorByMatrix(double[] vector, double[] matrix){//row-major
        if(matrix.length%vector.length != 0) return null;
        double[] newMatrix = new double[matrix.length/vector.length];
        for(int i = 0;i<matrix.length;i++){
            newMatrix[i/(newMatrix.length)] += vector[i%newMatrix.length]*matrix[(i%newMatrix.length)*newMatrix.length + i/newMatrix.length];
        }
        return newMatrix;
    }

    public static float[] vectorByMatrix(float[] vector, float[] matrix){//row-major
        if(matrix.length%vector.length != 0) return null;
        float[] newMatrix = new float[matrix.length/vector.length];
        for(int i = 0;i<matrix.length;i++){
            newMatrix[i/(newMatrix.length)] += vector[i%newMatrix.length]*matrix[(i%newMatrix.length)*newMatrix.length + i/newMatrix.length];
        }
        return newMatrix;
    }

    public static double[] transpose(double[] matrix,int width){
        double[] newMatrix = new double[matrix.length];
        int height = matrix.length/width;
        for(int i = 0;i<matrix.length;i++){
            newMatrix[i] = matrix[i/height + (i%(height))*width];
        }
        return newMatrix;
    }

    public static double[][] transpose(double[][] matrix){
        double[][] newMatrix = new double[matrix[0].length][matrix.length];
        for(int i = 0;i<matrix.length;i++){
            for(int j = 0;j<matrix[0].length;j++){
                newMatrix[i][j] = matrix[j][i];
            }
        }
        return newMatrix;
    }

    public static float[] transpose(float[] matrix,int width){
        float[] newMatrix = new float[matrix.length];
        int height = matrix.length/width;
        for(int i = 0;i<matrix.length;i++){
            newMatrix[i] = matrix[i/height + (i%(height))*width];
        }
        return newMatrix;
    }

    public static float[][] transpose(float[][] matrix){
        float[][] newMatrix = new float[matrix[0].length][matrix.length];
        for(int i = 0;i<matrix.length;i++){
            for(int j = 0;j<matrix[0].length;j++){
                newMatrix[i][j] = matrix[j][i];
            }
        }
        return newMatrix;
    }

    float[] globalizeAcceleration(float[] relativeAcceleration, float[] rotMatrix){
        float[] inverseRotMatrix = transpose(rotMatrix,(int) Math.sqrt(rotMatrix.length));
        float[] globalizedAcceleration = vectorByMatrix(relativeAcceleration,inverseRotMatrix);
        return globalizedAcceleration;
    }

    double[] globalizeAcceleration(double[] relativeAcceleration, double[] rotMatrix){
        double[] inverseRotMatrix = transpose(rotMatrix,(int) Math.sqrt(rotMatrix.length));
        double[] globalizedAcceleration = vectorByMatrix(relativeAcceleration,inverseRotMatrix);
        return globalizedAcceleration;
    }

    double[] globalizeAcceleration(double[] relativeAcceleration, long time){
        double[] globalAxl = relativeAcceleration;
        float[] rotMatrixf = getRotMatrixAt(time);
        double[] rotMatrix = new double[rotMatrixf.length];
        for(int i = 0;i<rotMatrixf.length;i++) rotMatrix[i] = rotMatrixf[i];
        return globalizeAcceleration(relativeAcceleration,rotMatrix);
    }

    double[] getPos(){
        int axlSize = axl.size();//To avoid request new values (can create bug (null...))
        for(int i = lastIndex+1;i<axlSize;i++){
            Pair<Long,Float[]> prevAxl = axl.get(i-1);
            Pair<Long,Float[]> nextAxl = axl.get(i);//can be at the time

            double t = nextAxl.first/1e9 - prevAxl.first/1e9;

            Float[] relativeAxlF = nextAxl.second;
            double[] relativeAxl = new double[relativeAxlF.length];
            for(int j = 0;j<relativeAxlF.length;j++) relativeAxl[j] = relativeAxlF[j];

            double[] absoluteAxl = globalizeAcceleration(relativeAxl,nextAxl.first);
            for(int j = 0;j<3;j++) absoluteAxl[j] -= gravity[j];

            double[] pos = new double[3];
            for(int j = 0;j<3;j++){
                //absoluteAxl[j]-=gravity[j];
                pos[j] = 0.5*absoluteAxl[j]*Math.pow(t,2) + lastSpeed[j]*t + lastPos[j];
                lastSpeed[j] = lastSpeed[j]+absoluteAxl[j]*t;
                lastPos[j] = pos[j];

                double cropUnder = 0.001;
                lastSpeed[j] = (lastSpeed[j]>cropUnder) ? lastSpeed[j] : 0;

            }
            lastIndex = i;

        }
        return lastPos;
    }

    double[] getRotAt(Long time){
        return getValAt(time,rot);
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

    <T> T[][] arrayToMatrix(T[] vector, int width){
         T[][] matrix = (T[][]) new Object[width][vector.length/width];//Can fail
        for(int i = 0;i<width;i++){
            for(int j = 0;j<vector.length/width;j++){
                matrix[i][j] = vector[j*width+i];
            }
        }
        return matrix;
    }


    float[] getRotMatrixAt(Long time){//Need application of interpolation and need to verify
        for(int i = matrixRot.size()-2;i>=0;i--){//-2 to avoid null fields
            if(matrixRot.get(i).first <= time){
                return matrixRot.get(i).second;
            }
        }
        return null;
    }

    double[] getValAt(Long time, ArrayList<Pair<Long,Float[]>> values){
        int valuesCount = values.size();

        double[] value = new double[3];
        int valuesEndIndex = 0;
        for(int i = valuesCount-2;i>=0;i--){
            if(values.get(i).first < time ){
                valuesEndIndex = i+1;
                break;
            }
        }

        Pair<Long,Float[]> prevVal;
        Pair<Long,Float[]> nextVal;//can be at the time

        nextVal = values.get(valuesEndIndex);
        prevVal = values.get(valuesEndIndex-1);

        double t = time-prevVal.first;
        double f = (t/(nextVal.first-prevVal.first));
        for(int i = 0;i<3;i++){
            value[i] = (nextVal.second[i]*f + prevVal.second[i] * (1-f));
        }

        return value;
    }

}

class PosSender implements Runnable{
    long wait;
    MainActivity mainActivity;
    String adress;
    int port;
    PosSender(long wait, MainActivity mainActivity,String adress, int port){
        this.wait = wait;
        this.mainActivity = mainActivity;
        this.adress = adress;
        this.port = port;
    }
    @Override
    public void run() {
        try {
            Socket socket = new Socket(adress,port);
            DataOutputStream outputStream = new DataOutputStream(socket.getOutputStream());
            System.out.println("Started");
        while(true) {
            long timeMillis1 = System.currentTimeMillis();
            if (mainActivity.axl.size() > 4 && mainActivity.matrixRot.size() > 4) {

            double[] posToSend = mainActivity.getPos();
            Float[] axlToSend = mainActivity.axl.get(mainActivity.axl.size()-1).second;
            float[] rotMatrixToSend = mainActivity.matrixRot.get(mainActivity.matrixRot.size()-1).second;

            if(posToSend!=null && axlToSend!=null && rotMatrixToSend!=null) {
                outputStream.writeDouble(posToSend[0]);
                outputStream.writeDouble(posToSend[1]);
                outputStream.writeDouble(posToSend[2]);
                outputStream.writeFloat((float) (axlToSend[0]));
                outputStream.writeFloat((float) (axlToSend[1]));
                outputStream.writeFloat((float) (axlToSend[2]));
                for(int i = 0;i<9;i++) outputStream.writeFloat(rotMatrixToSend[i]);
                outputStream.flush();
                long timeMillis2 = timeMillis1 - System.currentTimeMillis();
                try {
                    Thread.sleep(wait - timeMillis2);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }else{
                System.out.println("null");
            }
            }
        }

        } catch (IOException e) {
            //mainActivity.setStatus(e.toString());
            e.printStackTrace();
        }

    }


}
