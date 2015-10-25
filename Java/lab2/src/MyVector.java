import java.util.*;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

public class MyVector {

    private double[] data;
    private int size;

    public MyVector(int size){
        this.size = size;
        this.data = new double[size];
    }

    public MyVector(double[] data) {
        this(data.length);
        for (int i = 0; i < size; i++)
            this.data[i] = data[i];
    }

    public MyVector(MyVector myVector) {
        this(myVector.size);
        for (int i = 0; i < size; i++)
            this.data[i] = myVector.data[i];
    }

    public int getSize(){
        return size;
    }

    public boolean compare (MyVector myVector){
        if (myVector.size!=size) return false;
        for (int i=0; i< size;i++)
            if (data[i] != myVector.data[i])
                return false;
        return true;
    }
    public MyVector add(MyVector myVector){
        if (myVector.size!=size) return this;
        for (int i=0; i< size;i++)
            data[i] += myVector.data[i];
        return this;
    }

    public MyVector multi(double k){
        for (int i=0; i< size;i++)
            data[i] *= k;
        return this;
    }

    public double getElement(int index){
        return data[index];
    }

    public void setElement(int index, double value){
        if (index<0 || index>size-1) return;
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

    public void sort(){
        Sort.selectionSort(this);
    }

}

