package vector;

/**
 * Created by Jeka on 12.10.2015.
 */
public interface Vector {
    void fillFromMass(double[] data);

    void fillFromVector(ArrayVector arrayVector);

    int getSize();

    boolean equal(ArrayVector arrayVector);

    ArrayVector sum(ArrayVector arrayVector) throws IncompatibleVectorSizesException;

    ArrayVector mult(double k);

    double getElement(int index);

    void setElement(int index, double value);
}
