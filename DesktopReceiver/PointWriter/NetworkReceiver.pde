import java.net.ServerSocket;
import java.net.Socket;
import java.io.*;

public class NetworkReceiver implements Runnable{
  int port;
  public NetworkReceiver(int port){
  this.port = port;
  }
  
  boolean running = true;
  
  void run(){
    try{
    ServerSocket server = new ServerSocket(port);
    while(running){
    println("Listening for connection");
    Socket socket = server.accept();
    println("New Client");
    DataInputStream inputStream = new DataInputStream(socket.getInputStream());
    PointWriter.points.add(new ArrayList<Float[]>());
    while (running && socket.isConnected()) {
                ///if (inputStream.available() > 0) {
                    Float[] pos = new Float[3];
                    for(int i = 0;i<3;i++){
                        pos[i] = (float) inputStream.readDouble()*250;
                    }
                    Float[] axl = new Float[3];
                    for(int i = 0;i<3;i++){
                        axl[i] = inputStream.readFloat();
                    }
                    Float[] rotMatrix = new Float[9];
                    for(int i = 0;i<9;i++){
                        rotMatrix[i] = inputStream.readFloat();
                    }
                    PointWriter.rotMatrix = new double[3][3];
                    for(int i = 0;i<3;i++){
                    for(int j = 0;j<3;j++){
                      PointWriter.rotMatrix[i][j] = rotMatrix[i*3+j];
                    }
                    }
                    //PointWriter.axl = axl;
                    //val[1] = 0f;
                    PointWriter.points.get(0).add(pos);
                    println("New vertex : " + Arrays.toString(pos));
                    //PointWriter.rotate[2] = PointWriter.rotate[2].isNaN() ? - PI/2 : PointWriter.rotate[2];
                  // System.out.println("Rotate : " + Arrays.toString(val2) + " and set : " + Arrays.toString(PointWriter.rotate));
                //
            }
            println("Client Disconnected");
    }
    server.close();
    }catch(IOException e){
    }
  }
}
