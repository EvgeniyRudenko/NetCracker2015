package vector;

import vector.impl.ArrayVector;

/**
 * Created by Jeka on 12.10.2015.
 */
public interface Vector {

    void fillFromMass(double[] data);

    void fillFromVector(Vector vector);

    boolean equals(Object obj);

    Vector sum(Vector vector) throws IncompatibleVectorSizesException;

    Vector mult(double k);

    int getSize();

    double getElement(int index);

    void setElement(int index, double value);

    void addElement(double value);

    void insertElement(int index, double value);

    void deleteElement(int index);

    String toString();

    Object clone () throws CloneNotSupportedException;

}
