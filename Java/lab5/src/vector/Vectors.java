package vector;

import vector.impl.ArrayVector;

import java.io.*;

/**
 * Created by Jeka on 15.10.2015.
 */
public class Vectors {

    public static void selectionSort(Vector arrayVector){
        for (int i = 0; i < arrayVector.getSize(); i++) {
            double min = arrayVector.getElement(i);
            int min_i = i;
            for (int j = i+1; j < arrayVector.getSize(); j++) {
                if (arrayVector.getElement(j) < min) {
                    min = arrayVector.getElement(j);
                    min_i = j;
                }
            }
            if (i != min_i) {
                double tmp = arrayVector.getElement(i);
                arrayVector.setElement(i, arrayVector.getElement(min_i));
                arrayVector.setElement(min_i,tmp);
            }
        }
    }

    public static void outputVector(Vector v, OutputStream out) throws IOException{
        DataOutputStream dataOut = new  DataOutputStream(out);
        dataOut.writeInt(v.getSize());
        for (int i = 0; i < v.getSize(); i++) {
            dataOut.writeDouble(v.getElement(i));
        }
    }

    public static Vector inputVector(InputStream in) throws IOException{
        DataInputStream dataIn = new DataInputStream(in);
        int len = dataIn.readInt();
        ArrayVector v = new ArrayVector(len);
        for (int i = 0; i < len; i++) {
            v.setElement(i,dataIn.readDouble());
        }
        return v;
    }

    public static void writeVector(Vector v, Writer out) throws IOException {
        out.write(v.getSize() + " " + v + "\n");
    }

    public static Vector readVector(Reader in) throws IOException {
        StreamTokenizer st = new StreamTokenizer(in);
        int len=0;
        if (st.nextToken()==StreamTokenizer.TT_NUMBER)
            len = (int)st.nval;
        ArrayVector v = new ArrayVector(len);
        int i=0;
        while(st.nextToken()==StreamTokenizer.TT_NUMBER){
            v.setElement(i,st.nval);
            i++;
        };
        return v;
    }
}


