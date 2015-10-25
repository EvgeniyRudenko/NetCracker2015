package vector.impl;

import vector.Vector;
import vector.VectorTest;
import vector.Vectors;

import java.io.*;
import java.util.ArrayList;

public class Main{

    static String userName = System.getProperty("user.name");
    static String filePath = "C:\\Users\\" + userName + "\\Desktop\\";
    
    public static void main(String[] args){
        double d[]={1.1, 3, 5, -5};
        ArrayVector a = new ArrayVector(d);

        FileOutputStream file = null;
        try {
            file = new FileOutputStream(filePath + "byteio.txt");
            Vectors.outputVector(a, file);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();  
        } finally{
            try {
                file.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }

        FileWriter file2 = null;
        try {
            file2 = new FileWriter(filePath + "chario.txt");
            Vectors.writeVector(a, file2);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                file2.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }

        FileInputStream file3 = null;
        try {
            file3 = new FileInputStream(filePath + "byteio.txt");
            ArrayVector b = null;
            b = (ArrayVector)Vectors.inputVector(file3);
            System.out.println(b);
        } catch (FileNotFoundException e) {
            e.printStackTrace();  
        } catch (IOException e) {
            e.printStackTrace();  
        }finally{
            try {
                file3.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }

        FileReader file4 = null;
        try {
            file4 = new FileReader(filePath + "chario.txt");
            ArrayVector c = null;
            c = (ArrayVector)Vectors.readVector(file4);
            System.out.println(c);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                file4.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        FileOutputStream file5 = null;
        try {
            file5 = new FileOutputStream(filePath + "arrayV.txt");
            ObjectOutputStream outStream = new ObjectOutputStream(file5);
            outStream.writeObject(a);

        } catch (FileNotFoundException e) {
            e.printStackTrace();  
        } catch (IOException e) {
            e.printStackTrace();  
        }
        finally{
            try {
                file5.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }

        FileInputStream file6 = null;
        try {
            file6 = new FileInputStream(filePath + "arrayV.txt");
            ObjectInputStream inStream = new ObjectInputStream(file6);
            Object o =  inStream.readObject();
            ArrayVector e = (ArrayVector) o;
            System.out.println(e);
        } catch (FileNotFoundException e) {
            e.printStackTrace();  
        } catch (IOException e) {
            e.printStackTrace();  
        } catch (ClassNotFoundException e) {
            e.printStackTrace();  
        } finally{
            try {
                file6.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }

        LinkedVector linkedVector = new LinkedVector();
        linkedVector.addElement(2.3);
        linkedVector.addElement(1.3);
        linkedVector.addElement(5.0);
        linkedVector.addElement(-1.3);
        linkedVector.addElement(7);
        System.out.println(linkedVector);

        FileOutputStream file7 = null;

        try {
            file7 = new FileOutputStream(filePath + "linkedV.txt");
            ObjectOutputStream outStream = new ObjectOutputStream(file7);
            outStream.writeObject(linkedVector);

        } catch (FileNotFoundException e) {
            e.printStackTrace();  
        } catch (IOException e) {
            e.printStackTrace();  
        }
        finally{
            try {
                file7.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }

        FileInputStream file8 = null;
        try {
            file8 = new FileInputStream(filePath + "linkedV.txt");
            ObjectInputStream inStream = new ObjectInputStream(file8);
            Object o =  inStream.readObject();
            LinkedVector e = (LinkedVector) o;
            System.out.println(e);
        } catch (FileNotFoundException e) {
            e.printStackTrace();  
        } catch (IOException e) {
            e.printStackTrace();  
        } catch (ClassNotFoundException e) {
            e.printStackTrace();  
        } finally{
            try {
                file8.close();
            } catch (IOException e) {
                e.printStackTrace();  
            }
        }
    }

}
