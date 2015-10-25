package vector.impl;

import sun.plugin.javascript.navig.Array;
import vector.*;
import vector.Vector;

import java.io.Serializable;
import java.util.*;

public class ArrayVector implements vector.Vector, Cloneable, Serializable {

    protected double[] data;
    private int size;

    public ArrayVector(int size){
        if  (size<0)
            throw new IllegalArgumentException("Wrong size: " + size);
        this.size = size;
        this.data = new double[size];
    }

    public ArrayVector(double[] data) {
        this.size = data.length;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
            this.data[i] = data[i];
    }

    public ArrayVector(ArrayVector vector) {
        this.size = vector.size;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
            this.data[i] = vector.data[i];
    }

    @Override
    public void fillFromMass(double[] data){
        this.size = data.length;
        this.data = new double[size];
        for (int i = 0; i < size; i++)
        this.data[i] = data[i];
    }

    @Override
    public void fillFromVector(Vector vector) {
        this.size = vector.getSize();
        this.data = new double[size];
        for (int i = 0; i < size; i++)
            this.data[i] = vector.getElement(i);
    }

    @Override
    public int getSize(){
        return size;
    }

    @Override
    public boolean equals(Object obj){
        if (this == obj) return true;
        if (!(obj instanceof Vector)) return false;
        Vector vector = (Vector) obj;
        if (vector.getSize()!=size) return false;
        for (int i=0; i< size;i++)
            if (data[i] != vector.getElement(i))
                return false;
        return true;
    }

    @Override
    public int hashCode() {
        int result = data != null ? Arrays.hashCode(data) : 0;
        result = 31 * result + size;
        return result;
    }

    @Override
    public Vector sum(Vector vector) throws IncompatibleVectorSizesException{
        if (vector.getSize()!=size) throw new IncompatibleVectorSizesException("Vectors have different sizes");
        for (int i=0; i< size;i++)
            data[i] += vector.getElement(i);
        return this;
    }

    @Override
    public Vector mult(double k){
        for (int i=0; i< size;i++)
            data[i] *= k;
        return this;
    }

    @Override
    public double getElement(int index){
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        return data[index];
    }

    @Override
    public void setElement(int index, double value){
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException ("Incorrect index: " + index);
            data[index]=value;
    }

    public double getMinElement(){
        double min = data[0];
        for (int i=1; i< size;i++)
            if (data[i] < min) min = data[i] ;
        return min;
    }

    public double getMaxElement(){
        double max = data[0];
        for (int i=1; i< size;i++)
            if (data[i] > max) max = data[i] ;
        return max;
    }
    @Override
    public void addElement(double value){
        size++;
        double[] newData = new double[size];
        System.arraycopy(data,0,newData,0,size-1);
        newData[size-1]=value;
        data = newData;
    }

    @Override
    public void insertElement(int index, double value){
        if (index<0 || index>size) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        size++;
        double[] newData = new double[size];
        System.arraycopy(data,0,newData,0,index);
        System.arraycopy(data,index,newData,index+1,size-1-index);
        newData[index]=value;
        data=newData;
    }

    @Override
    public void deleteElement(int index){
        if (index<0 || index>size-1) throw new VectorIndexOutOfBoundsException("Incorrect index: " + index);
        size--;
        double[] newData = new double[size];
        System.arraycopy(data,0,newData,0,index);
        System.arraycopy(data,index+1,newData,index,size-index);
        data=newData;
    }

    @Override
    public String toString () {
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < size; i++)
            str.append(data[i] + " ");
        str.deleteCharAt(str.length()-1);
        return str.toString();
    }

    @Override
    public ArrayVector clone() throws CloneNotSupportedException {
        ArrayVector newArr = (ArrayVector) super.clone();
        newArr.data = data.clone();
        return newArr;
    }

    public void sort(){
        Vectors.selectionSort(this);
    }

}

